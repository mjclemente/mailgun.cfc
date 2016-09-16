# mailguncfc
A CFML wrapper for the MailGun API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc).

Your account credentials can be found on the dashboard of your Mailgun account: <https://mailgun.com/app/dashboard>.

![Mailgun API Keys](/assets/images/api-keys.png)

Currently both your Secret API Key and your Public API Key must be provided. The former is used for most operations, but the latter is used for email validation calls.

# Getting Started

	mailGun = new com.mailgun( secretApiKey = 'key-xxx', publicApiKey = 'pubkey-xxx', domain = 'yourdomain.com', baseUrl = 'https://api.mailgun.net/v3' );