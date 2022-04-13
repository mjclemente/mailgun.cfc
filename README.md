# mailguncfc
A CFML wrapper for the MailGun API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc). Because it draws on that project, it is also licensed under the terms of the Apache License, Version 2.0.

# Table of Contents

- [Installation](#installation)
- [Standalone Usage](#standalone-usage)
- [Use as a ColdBox Module](#use-as-a-coldbox-module)
- [Available Methods](#available-methods)
- [Mailgun Account Credentials](#mailgun-account-credentials)
- [Questions](#questions)
- [Contributing](#contributing)
- [Changelog](#changelog)

# Installation
This wrapper can be installed as standalone component or as a ColdBox Module. Either approach requires a simple CommandBox command:

```
$ box install mailguncfc
```

If you can't use CommandBox, all you need to use this wrapper as a standalone component is the `mailgun.cfc` file; just add it to your application wherever you store cfcs. But you should really be using CommandBox.

# Standalone Usage

This component will be installed into a directory called `mailguncfc` in whichever directory you have chosen and can then be instantiated directly like so:

```cfc
mailgun = new mailguncfc.mailgun(
  secretApiKey = 'key-xxx',
  publicApiKey = 'pubkey-xxx',
  domain = 'yourdomain.com'
);
```

With all optional arguments included

```cfc
mailgun = new mailguncfc.mailgun(
  secretApiKey      = 'key-xxx',
  publicApiKey      = 'pubkey-xxx',
  domain            = 'yourdomain.com',
  baseUrl           = 'https://api.mailgun.net/v3',
  forceTestMode     = false,
  httpTimeout       = 60, 
  includeRaw        = true, 
  webhookSigningKey = 'key-xxx'
);
```

# Use as a ColdBox Module

To use the wrapper as a ColdBox Module you will need to pass the configuration settings in from your `config/Coldbox.cfc`. This is done within the `moduleSettings` struct:

```cfc
moduleSettings = {
  mailguncfc = {
    secretApiKey  = 'key-xxx',
    publicApiKey  = 'pubkey-xxx',
    domain        = 'yourdomain.com'
  }
};
```

You can then leverage the CFC via the injection DSL: `mailgun@mailguncfc`:

```
property name="mailgun" inject="mailgun@mailguncfc";
```


# Available Methods
***Note that the Mailgun API has more methods available. This is a list of those currently available in this wrapper. I'll be adding more as time permits and needs dictate.***

#### Validation: <https://documentation.mailgun.com/api-email-validation.html>

```cfc
validate( required string address, boolean mailbox_verification = false, boolean private = true )
```

#### Messages: <https://documentation.mailgun.com/api-sending.html>

```cfc
sendMessage( string domain = variables.domain, required string from, required string to, string cc, string bcc, string subject, string text = "", string html = "", any attachment, any inline, struct o = { }, struct h = { }, struct v = { }, any recipient_variables )

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

#### Webhooks: https://documentation.mailgun.com/en/latest/user_manual.html?#webhooks-1

```
verifySignature( required any timestamp, required string token, required string signature )
```


# Mailgun Account Credentials
Your account credentials can be found on the dashboard of your Mailgun account: <https://mailgun.com/app/dashboard>.

![Mailgun API Keys](/assets/images/api-keys.png)

Currently both your Secret API Key and your Public API Key must be provided. The Secret API Key is used for most operations. In prior versions, email validation calls used the Public API Key. However, now that Mailgun has moved to a usage based pricing model for their email validation, the default for email validation calls is also to use the Secret API Key. The Public API Key requirement will likely be removed in later versions. It's currently included, so that calls can explicitly be made to the public endpoint of the email validation API.

# Questions
For questions that aren't about bugs, feel free to hit me up on the [CFML Slack Channel](http://cfml-slack.herokuapp.com); I'm @mjclemente. You'll likely get a much faster response than creating an issue here.

# Contributing
:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

Before putting the work into creating a PR, I'd appreciate it if you opened an issue. That way we can discuss the best way to implement changes/features, before work is done.

Changes should be submitted as Pull Requests on the `develop` branch.

# Changelog

## 2018-05-04
Thanks [@coldfumonkeh](https://github.com/coldfumonkeh)

### Added
* Ability to use as a ColdBox module

## 2018-04-26
Thanks [@ericleversen](https://github.com/ericleversen)

### Added
* `recipient_variables` support to `sendMessage()`

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

Thanks [@mjhagen](https://github.com/mjhagen)

### Added
* Two list management functions:
 * createList()
 * createListMembers()

### Changed
* Expanded the error reporting by deserializing the returned message
and adding that to the error detail.
