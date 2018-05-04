component {

	this.title = "MailGun API";
	this.author = "Matthew J. Clemente";
	this.webURL = "https://github.com/mjclemente/mailgun.cfc";
	this.description = "A wrapper for the MailGun API";

	/**
	 * Configure
	 */
	function configure(){

		// Settings
		settings = {
			secretApiKey  = '', // Required
			publicApiKey  = '', // Required
			domain        = '', // Default value in init
			baseUrl       = 'https://api.mailgun.net/v3', // Default value in init
			forceTestMode = false, // Default value in init
			httpTimeout   = 60, // Default value in init
			includeRaw    = true // Default value in init
		};
	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		parseParentSettings();
		var mailGunAPISettings = controller.getConfigSettings().mailGun;

		// Map Library
		binder.map( "mailGun@mailGun" )
			.to( "#moduleMapping#.mailgun" )
			.initArg( name="secretApiKey", value=mailGunAPISettings.secretApiKey )
			.initArg( name="publicApiKey", value=mailGunAPISettings.publicApiKey )
			.initArg( name="domain", value=mailGunAPISettings.domain )
			.initArg( name="baseUrl", value=mailGunAPISettings.baseUrl )
			.initArg( name="forceTestMode", value=mailGunAPISettings.forceTestMode )
			.initArg( name="httpTimeout", value=mailGunAPISettings.httpTimeout )
			.initArg( name="includeRaw", value=mailGunAPISettings.includeRaw );
	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){
	}

	/**
	* parse parent settings
	*/
	private function parseParentSettings(){
		var oConfig      = controller.getSetting( "ColdBoxConfig" );
		var configStruct = controller.getConfigSettings();
		var mailGunDSL   = oConfig.getPropertyMixin( "mailGun", "variables", structnew() );

		//defaults
		configStruct.mailGun = variables.settings;

		// incorporate settings
		structAppend( configStruct.mailGun, mailGunDSL, true );
	}

}