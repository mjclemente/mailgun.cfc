# salesforceiqcfc
A CFML wrapper for the SalesforceIQ API

This project borrows heavily from the API framework built by [jcberquist](https://github.com/jcberquist) with [stripecfc](https://github.com/jcberquist/stripecfc).

# Getting Started

	salesforceiq = new path.to.salesforceiq( apiKey = 'xxx', apiSecret = 'xxx' );

# Available Methods

***Note that for the create() methods, the structs passed in are case sensitive - use array notation when creating them.***

#### Accounts [https://api.salesforceiq.com/#/curl#documentation_accounts_account-object](https://api.salesforceiq.com/#/curl#documentation_accounts_account-object)

	createAccount( required struct newAccount )
	
	updateAccount( required string accountId, required struct updatedAccount )
	
	getAccount( required string accountId )

	listAccounts( array _ids, numeric _start = "0", numeric _limit = "50", string _modifiedDate   )
	
#### Contacts [https://api.salesforceiq.com/#/curl#documentation_contacts_contact-object](https://api.salesforceiq.com/#/curl#documentation_contacts_contact-object)

	createContact( required struct newContact )
	
	upsertContact( required struct newContact )
  
	updateContact( required string contactId, required struct updatedContact )
	  
	getContact( required string contactId ) {

    listContacts( array _ids, numeric _start = "0", numeric _limit = "20", string _modifiedDate )

#### Lists [https://api.salesforceiq.com/#/curl#documentation_lists_list-object](https://api.salesforceiq.com/#/curl#documentation_lists_list-object)


	getList( required string listId ) {

	listLists( array _ids, numeric _start = "0", numeric _limit = "20" )
	
#### List Items [https://api.salesforceiq.com/#/curl#documentation_lists_list-items](https://api.salesforceiq.com/#/curl#documentation_lists_list-items)

	createListItem( required string listId, required struct newListItem )
	
	upsertListItem( required string listId, required struct newListItem, required string upsertType )
	
	updateListItem( required string listId, required string itemId, required struct updatedListItem )
		
	getListItem( required string listId, required string itemId )
	
	deleteListItem( required string listId, required string itemId )	
	listListItems( required string listId, array _ids, numeric _start = "0", numeric _limit = "20", string _modifiedDate )

#### Fields [https://api.salesforceiq.com/#/curl#documentation_accounts_account-fields_account-field-object](https://api.salesforceiq.com/#/curl#documentation_accounts_account-fields_account-field-object)

	listAccountFields( )