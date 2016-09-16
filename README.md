# mailguncfc
A CFML wrapper for the MailGun API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc).

Your account credentials can be found on the dashboard of your Mailgun account: <https://mailgun.com/app/dashboard>.

![Mailgun API Keys](/assets/images/api-keys.png)

Currently both your Secret API Key and your Public API Key must be provided. The former is used for most operations, but the latter is used for email validation calls.

# Getting Started

```cfc
mailGun = new com.mailgun( secretApiKey = 'key-xxx', publicApiKey = 'pubkey-xxx', domain = 'yourdomain.com', baseUrl = 'https://api.mailgun.net/v3' );
```

# Available Methods
***Note that the Mailgun API has more methods available. This is a list of those currently available in this wrapper. I'll be adding more as time permits and needs dictate.***

#### Validation: <https://documentation.mailgun.com/api-email-validation.html>

```cfc
validate( required string address )
```
	
#### Messages: <https://documentation.mailgun.com/api-sending.html>
	
```cfc
sendMessage( string domain = variables.domain, required string from, required string to, string cc, string bcc, string subject, string text = "", string html = "", any attachment, any inline, struct o = { }, struct h = { }, struct v = { } )
```

#### Supressions: <https://documentation.mailgun.com/api-suppressions.html>

```cfc
getBounces( string domain = variables.domain, numeric limit = 100 )
```

#### Mailing Lists: <https://documentation.mailgun.com/api-mailinglists.html>

```cfc
getLists()

getList( required string listaddress, numeric limit = 100, numeric skip = 0 )

createListMember( required string listaddress, required string address, string name, string vars, boolean subscribed = true, boolean upsert = false )
```

# Changelog
	
	