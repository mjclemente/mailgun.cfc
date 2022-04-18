component {

	this.title = "MailGun API";
	this.author = "Matthew J. Clemente";
	this.webURL = "https://github.com/mjclemente/mailgun.cfc";
	this.description = "A wrapper for the MailGun API";

	function configure(){
		settings = {
			secretApiKey      = '', // Required
			publicApiKey      = '', // Required
			domain            = '', // Default value in init
			baseUrl           = 'https://api.mailgun.net/v3', // Default value in init
			forceTestMode     = false, // Default value in init
			httpTimeout       = 60, // Default value in init
			includeRaw        = true, // Default value in init,
			webhookSigningKey = '' // Default value in init
		};
	}

  function onLoad() {
    binder.map( "mailgun@mailguncfc" )
      .to( "#moduleMapping#.mailgun" )
      .asSingleton()
      .initWith(
        secretApiKey = settings.secretApiKey,
        publicApiKey = settings.publicApiKey,
        domain = settings.domain,
        baseUrl = settings.baseUrl,
        forceTestMode = settings.forceTestMode,
        httpTimeout = settings.httpTimeout,
        includeRaw = settings.includeRaw,
        webhookSigningKey = settings.webhookSigningKey
      );
  }

}