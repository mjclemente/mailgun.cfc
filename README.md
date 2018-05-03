# mailguncfc
A CFML wrapper for the MailGun API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc). Because it draws on that project, it is also licensed under the terms of the Apache License, Version 2.0.

Your account credentials can be found on the dashboard of your Mailgun account: <https://mailgun.com/app/dashboard>.

![Mailgun API Keys](/assets/images/api-keys.png)

Currently both your Secret API Key and your Public API Key must be provided. The Secret API Key is used for most operations. In prior versions, email validation calls used the Public API Key. However, now that Mailgun has moved to a usage based pricing model for their email validation, the default for email validation calls is also to use the Secret API Key. The Public API Key requirement will likely be removed in later versions. It's currently included, so that calls can explicitly be made to the public endpoint of the email validation API.

# Installation
This wrapper can be installed as standalone or as a ColdBox Module. Either approach requires a simple CommandBox command:

`box install mailguncfc`

## Standalone

This component will be installed into a directory called `mailguncfc` in whichever directory you have chosen and can then be instantiated directly like so:

```
new mailguncfc.mailgun(
	secretApiKey  = '', // Required
	publicApiKey  = '', // Required
	domain        = '', // Default value in init
	baseUrl       = 'https://api.mailgun.net/v3', // Default value in init
	forceTestMode = false, // Default value in init
	httpTimeout   = 60, // Default value in init
	includeRaw    = true // Default value in init
);
```

## ColdBox Module

To use the component as a ColdBox Module you will need to create a configuration object in your applications configuration file: `config/Coldbox.cfc` with the following settings:

```
mailGun = {
	secretApiKey  = '', // Required
	publicApiKey  = '', // Required
	domain        = '', // Default value in init
	baseUrl       = 'https://api.mailgun.net/v3', // Default value in init
	forceTestMode = false, // Default value in init
	httpTimeout   = 60, // Default value in init
	includeRaw    = true // Default value in init
}
```

You can then leverage the CFC via the injection DSL: `mailGun@mailGun`:

```
property name="mailGun" inject="mailGun@mailGun";
```


# Getting Started

```cfc
mailGun = new com.mailgun( secretApiKey = 'key-xxx', publicApiKey = 'pubkey-xxx', domain = 'yourdomain.com', baseUrl = 'https://api.mailgun.net/v3' );
```

# Available Methods
***Note that the Mailgun API has more methods available. This is a list of those currently available in this wrapper. I'll be adding more as time permits and needs dictate.***

#### Validation: <https://documentation.mailgun.com/api-email-validation.html>

```cfc
validate( required string address, boolean mailbox_verification = false, boolean private = true )
```

#### Messages: <https://documentation.mailgun.com/api-sending.html>

```cfc
sendMessage( string domain = variables.domain, required string from, required string to, string cc, string bcc, string subject, string text = "", string html = "", any attachment, any inline, struct o = { }, struct h = { }, struct v = { } )

getStoredMessage( required string messageUrl )
```

#### Supressions: <https://documentation.mailgun.com/api-suppressions.html>

```cfc
getBounces( string domain = variables.domain, numeric limit = 100 )
```

#### Stats: <https://documentation.mailgun.com/en/latest/api-stats.html>

```cfc
getStats( string domain = variables.domain, required string event, date start = '#now()#-7', date end = '#now()#', string resolution = 'day', string duration )
```

#### Mailing Lists: <https://documentation.mailgun.com/api-mailinglists.html>

```cfc
getLists()

getList( required string listaddress, numeric limit = 100, numeric skip = 0 )

createList( required string address, string name = "", string description = "", access_level = "readonly" )

createListMember( required string listaddress, required string address, string name, string vars, boolean subscribed = true, boolean upsert = false )

createListMembers( required string listaddress, required json members, boolean upsert = false )
```

# Changelog

## 2017-11-13

### Added
* Method `getStoredMessage()`, to retrieve an inbound message that has been stored via the Mailgun's `store()` action, using the URL found in the stored event
* Option `getStats()`, to return a domain's event statistics

## 2017-07-09

### Added
* Option `mailbox_verification`, to validate(), to enable a mailbox verification check to be performed against the address.
* Option `private`, to validate(), to override default and call public API endpoint

### Changed
* validate() now defaults to the private API endpoint


## 2016-12-29

Thanks @mjhagen

### Added
* Two list management functions:
 * createList()
 * createListMembers()

### Changed
* Expanded the error reporting by deserializing the returned message
and adding that to the error detail.
