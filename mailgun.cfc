/*
  Copyright (c) 2015, Matthew Clemente, John Berquist
  v0.2.0

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
component output="false" displayname="MainGun.cfc"  {

  variables.utcBaseDate = dateAdd( "l", createDate( 1970,1,1 ).getTime() * -1, createDate( 1970,1,1 ) );
  variables.integerFields = [ "limit", "skip" ];
  variables.numericFields = [  ];
  variables.timestampFields = [ "deliverytime", "start", "end" ];
  variables.booleanFields = [ "mailbox_verification", "dkim", "testmode", "tracking", "tracking-clicks", "tracking-opens", "require-tls", "skip-verification", "subscribed", "upsert" ];
  variables.arrayFields = [ "attachment", "inline", "tag" ];
  variables.fileFields = [ "attachment", "inline" ];
  variables.dictionaryFields = {
    o = { required = [ ], optional = [ "tag", "campaign", "dkim", "deliverytime", "testmode", "tracking", "tracking-clicks", "tracking-opens", "require-tls", "skip-verification" ] },
    h = { required = [ ], optional = [ ] },
    v = { required = [ ], optional = [ ] }
  };

  public any function init( required string secretApiKey, required string publicApiKey, string domain = "", string baseUrl = "https://api.mailgun.net/v3", boolean forceTestMode = false, numeric httpTimeout = 60, boolean includeRaw = true ) {

    structAppend( variables, arguments );
    return this;
  }

  //VALIDATION
  public struct function validate( required string address, boolean mailbox_verification = false, boolean private = true ) {

    return apiCall( "/address#private ? '/private' : ''#/validate", setupParams( arguments ), "get", private );
  }

  public struct function sendMessage( string domain = variables.domain, required string from, required string to, string cc, string bcc, string subject, string text = "", string html = "", any attachment, any inline, struct o = { }, struct h = { }, struct v = { } ) {

    return apiCall( "/#trim( domain )#/messages", setupParams( arguments ), "post" );
  }

  /**
  * @hint The URL messages are stored at is different than the standard API endpoint. Furthermore, the URL where a message is stored is only returned from 1) a webhook or 2) a previous api call. Consequently, the structure of this method is a little different than others.
  * @messageUrl The complete url location the message is stored at. Returned from a webhook for the message, or an api call to the events endpoint for stored messages
  */
  public struct function getStoredMessage( required string messageUrl ) {
    return apiCall( messageUrl, [], "get" );
  }

  //STATS
  public struct function getStats( string domain = variables.domain, required string event, date start = '#now()#-7', date end = '#now()#', string resolution = 'day', string duration  ) {

    return apiCall( "/#trim( domain )#/stats/total", setupParams( arguments ), "get" );
  }

  //Mailing Lists
  public struct function getLists( ) {

    return apiCall( "/lists", setupParams( arguments ), "get" );
  }

  public struct function getList( required string listaddress, numeric limit = 100, numeric skip = 0 ) {

    return apiCall( "/lists/#trim( listaddress )#", setupParams( arguments ), "get" );
  }

  /**
   * address      A valid email address for the mailing list, e.g. developers@mailgun.net, or Developers <devs@mg.net>
   * name         Mailing list name, e.g. Developers (optional)
   * description  A description (optional)
   * access_level List access level, one of: readonly (default), members, everyone
   */
  public struct function createList( required string address, string name = "", string description = "", access_level = "readonly" ) {
    return apiCall( "/lists", setupParams( arguments ), "post" );
  }

  //skipped implementing a few here

  //need a better way to handle the 'vars' field
  public struct function createListMember( required string listaddress, required string address, string name, string vars, boolean subscribed = true, boolean upsert = false  ) {

    return apiCall( "/lists/#trim( listaddress )#/members", setupParams( arguments ), "post" );
  }

  public struct function createListMembers( required string listaddress, required json members, boolean upsert = false ) {
    return apiCall(
      "/lists/#listaddress#/members.json",
      setupParams(
        {
          "members" = members,
          "upsert" = upsert
        }
      ),
      "post"
    );
  }

  //Supressions
  public struct function getBounces( string domain = variables.domain, numeric limit = 100 ) {

    return apiCall( "/#trim( domain )#/bounces", setupParams( arguments ), "get" );
  }



  // PRIVATE FUNCTIONS
  private struct function apiCall( required string path, array params = [ ], string method = "get", boolean private = true )  {

    //if relative path (default), append to base. If not, assume full url (retrieving messages), and use it
    var fullApiPath = path.left( 1 ) == '/' ? variables.baseUrl & path : path;

    var requestStart = getTickCount();


    var apiResponse = makeHttpRequest( urlPath = fullApiPath, params = params, method = method, private = private );

    if ( val( apiResponse.Statuscode ) >= 400 ) {
      var detail = "";

      if ( structKeyExists( apiResponse, "Filecontent" ) && isJson( apiResponse.Filecontent ) ) {
        var deserializedFilecontent = deserializeJSON( apiResponse.fileContent );

        if ( isStruct( deserializedFilecontent ) && structKeyExists( deserializedFilecontent, "message" ) ) {
          detail = deserializedFilecontent.message;
        }
      } else if ( structKeyExists( apiResponse, "ErrorDetail" ) && len( apiResponse.ErrorDetail ) ) {
        detail = apiResponse.ErrorDetail;
      } else if ( structKeyExists( apiResponse, "Responseheader" ) && structKeyExists( apiResponse.Responseheader, "Explanation" ) ) {
        detail = apiResponse.Responseheader.Explanation;
      }
      throwError( "error placing API call '#path#'.", detail );
    }

    var result = { "api_request_time" = getTickCount() - requestStart, "status_code" = listFirst( apiResponse.statuscode, " " ), "status_text" = listRest( apiResponse.statuscode, " " ) };
    if ( variables.includeRaw ) {
      result[ "raw" ] = { "method" = ucase( method ), "path" = fullApiPath, "params" = serializeJSON( params ), "response" = apiResponse.fileContent };
    }
    structAppend(  result, deserializeJSON( apiResponse.fileContent ), true );
    parseResult( result );
    return result;
  }

  private any function makeHttpRequest( required string urlPath, required array params, required string method, required boolean private ) {
    var http = new http( url = urlPath, method = method, username = "api", password = private ? secretApiKey : publicApiKey, timeout = variables.httpTimeout );

    // adding a user agent header so that Adobe ColdFusion doesn't get mad about empty HTTP posts
    http.addParam( type = "header", name = "User-Agent", value = "mailgun.cfc" );

    var qs = [ ];

    for ( var param in params ) {

      if ( method == "post" ) {
        if ( arraycontains( variables.fileFields , param.name ) ) {
          http.addParam( type = "file", name = lcase( param.name ), file = param.value );
        } else {
          http.addParam( type = "formfield", name = lcase( param.name ), value = param.value );
        }
      } else if ( arrayFind( [ "get","delete" ], method ) ) {
        arrayAppend( qs, lcase( param.name ) & "=" & encodeurl( param.value ) );
      }

    }

    if ( arrayLen( qs ) ) {
      http.setUrl( urlPath & "?" & arrayToList( qs, "&" ) );
    }

    return http.send().getPrefix();
  }

  private array function setupParams( required struct params ) {
    var filteredParams = { };
    var paramKeys = structKeyArray( params );
    for ( var paramKey in paramKeys ) {
      if ( structKeyExists( params, paramKey ) && !isNull( params[ paramKey ] ) ) {
        filteredParams[ paramKey ] = params[ paramKey ];
      }
    }
    if ( variables.forceTestMode ) {
      filteredParams["o"].testmode = true;
    }
    return parseDictionary( filteredParams );
  }

  private array function parseDictionary( required struct dictionary, string name = '', string root = '' ) {
    var result = [ ];
    var structFieldExists = structKeyExists( variables.dictionaryFields, name );

    // validate required dictionary keys based on variables.dictionaries
    if ( structFieldExists ) {
      for ( var field in variables.dictionaryFields[ name ].required ) {
        if ( !structKeyExists( dictionary, field ) ) {
          throwError( "'#name#' dictionary missing required field: #field#" );
        }
      }
    }

    // special tag handling -- tags have a 3 key limit
    if ( name == "tag" ) {
      if ( arrayLen( structKeyArray( dictionary ) ) > 3 ) {
        throwError( "There can be a maximum of 3 keys in a tag struct." );
      }
    }

    for ( var key in dictionary ) {

      // confirm that key is a valid one based on variables.dictionaries
      if ( structFieldExists && arguments.name != "h" && arguments.name != "o" && !( arrayFindNoCase( variables.dictionaryFields[ name ].required, key ) || arrayFindNoCase( variables.dictionaryFields[ name ].optional, key ) ) ) {
        throwError( "'#name#' dictionary has invalid field: #key#" );
      }

      var fullKey = len( root ) ? root & ':' & lcase( key ) : lcase( key );
      if ( isStruct( dictionary[ key ] ) ) {
        for ( var item in parseDictionary( dictionary[ key ], key, fullKey ) ) {
          arrayAppend( result, item );
        }
      } else if ( isArray( dictionary[ key ] ) ) {
        for ( var item in parseArray( dictionary[ key ], key, fullKey ) ) {
          arrayAppend( result, item );
        }
      } else {
        // note: metadata struct is special - no validation is done on it
        arrayAppend( result, { name = fullKey, value = getValidatedParam( key, dictionary[ key ], name != "o" && name != "h" ) } );
      }

    }

    return result;
  }

  private array function parseArray( required array list, string name = '', string root = '' ) {
    var result = [ ];
    var index = 0;
    var arrayFieldExists = arrayFindNoCase( variables.arrayFields, name );

    if ( !arrayFieldExists ) {
      throwError( "'#name#' is not an allowed list variable." );
    }

    for ( var item in list ) {
      if ( isStruct( item ) ) {
        var fullKey = len( root ) ? root & "[" & index & "]" : name & "[" & index & "]";
        for ( var item in parseDictionary( item, '', fullKey ) ) {
          arrayAppend( result, item );
        }
        ++index;
      } else {
        var fullKey = len( root ) ? root : name;
        arrayAppend( result, { name = fullKey, value = getValidatedParam( name, item ) } );
      }
    }

    return result;
  }

  private any function getValidatedParam( required string paramName, required any paramValue, boolean validate = true ) {
    // only simple values
    if ( !isSimpleValue( paramValue ) ) throwError( "'#paramName#' is not a simple value." );

    // integer
    if ( arrayFindNoCase( variables.integerFields, paramName ) ) {
      if ( !isInteger( paramValue ) ) {
        throwError( "field '#paramName#' requires an integer value" );
      }
      return paramValue;
    }
    // numeric
    if ( arrayFindNoCase( variables.numericFields, paramName ) ) {
      if ( !isNumeric( paramValue ) ) {
        throwError( "field '#paramName#' requires a numeric value" );
      }
      return paramValue;
    }

    // boolean
    if ( arrayFindNoCase( variables.booleanFields, paramName ) ) {
      return ( paramValue ? "true" : "false" );
    }

    // timestamp
    if ( arrayFindNoCase( variables.timestampFields, paramName ) ) {
      return parseUTCTimestampField( paramValue, paramName );
    }

    // default is string
    return paramValue;
  }

  private void function parseResult( required struct result ) {
    var resultKeys = structKeyArray( result );
    for ( var key in resultKeys ) {
      if ( structKeyExists( result, key ) && !isNull( result[ key ] ) ) {
        if ( isStruct( result[ key ] ) ) parseResult( result[ key ] );
        if ( isArray( result[ key ] ) ) {
          for ( var item in result[ key ] ) {
            if ( isStruct( item ) ) parseResult( item );
          }
        }
        if ( arrayFindNoCase( variables.timestampFields, key ) ) result[ key ] = parseUTCTimestampField( result[ key ], key );
      }
    }
  }

  private any function parseUTCTimestampField( required any utcField, required string utcFieldName ) {
    if ( isInteger( utcField ) ) return utcField;
    if ( isDate( utcField ) ) return getUTCTimestamp( utcField );
    throwError( "utc timestamp field '#utcFieldName#' is in an invalid format" );
  }

  private numeric function getUTCTimestamp( required date dateToConvert ) {
    return dateDiff( "s", variables.utcBaseDate, dateToConvert );
  }

  private date function parseUTCTimestamp( required numeric utcTimestamp ) {
    return dateAdd( "s", utcTimestamp, variables.utcBaseDate );
  }

  private boolean function isInteger( required any varToValidate ) {
    return ( isNumeric( varToValidate ) && isValid( "integer", varToValidate ) );
  }

  private string function encodeurl( required string str ) {
    return replacelist( urlEncodedFormat( str, "utf-8" ), "%2D,%2E,%5F,%7E", "-,.,_,~" );
  }

  private void function throwError( required string errorMessage, string detail = "" ) {
    throw( type = "MailGun", message = "(mailgun.cfc) " & errorMessage, detail = detail );
  }

}