const functions = require('firebase-functions');
const admin = require('firebase-admin');
// var express = require('express');
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref();

exports.webhookHandler = functions.https.onRequest((request, res) => {
	// Check for POST request
	if(request.method !== "POST"){
	 res.status(400).send('Please send a POST request');
	 return;
	}

	let data = JSON.parse(request.body);
		
		// send notification to user
		const user_id = data["user_id"];
		const text = "Your kitchen was just updated with recent purchases! Check it out!";
		const payload = {
			notification: {
				title : "Woot woot!",
				body: text,
				badge:'7',
				sound:'default',
			}
		};

	sendPushNotification( user_id, payload);
	insertIntoKitchen(data, user_id);
	res.status(200).send(data["user_id"]);
})


function sendPushNotification(user_id, payload){

	// get user fcmToken from FirebaseDatabase then send push notification to that token
	const userRefPromise = ref.child('users/'+user_id+'/fcmToken').once('value').then(function(snapshot) {
	  // var username = (snapshot.val() && snapshot.val().username) || 'Anonymous';
	  	console.log(snapshot);
	  	const fcmToken = (snapshot.val());
	  	console.log(fcmToken);
	  	const text = "Your kitchen was just updated with recent purchases! Check it out!";
		const senderName = user_id;
		const payload = {
		notification: {

			title :senderName,
			body: text,
			badge:'7',
			sound:'default',}
		};

		admin.messaging().sendToDevice([fcmToken], payload).then(response => {
		    // See the MessagingDevicesResponse reference documentation for
		    // the contents of response.
		    console.log('Successfully sent message:', response);
		    console.log(response.results[0].error);
		    return;
		}).catch(error => {
		    console.log('Error sending message:', error);
		    return;
		});
		return;
	});
	return;
}


function insertIntoKitchen(data, user_id) {
	console.log("Insert Into Kitchen");
	const purchaseData = data["purchase_data"];
	const purchasedItems = purchaseData["purchased_items"];

	purchasedItems.forEach(function (purchasedItem) {
    	const name = purchasedItem["name"];
    	console.log(name);
	    const productID = purchasedItem["product_id"];
	    ref.child('Users/'+user_id+'/FoodItems/'+name).set({
						 	"FoodItemName":name,
						 	"ProductID": productID,
						 });

    	const purchaseHistory = purchasedItem["purchase_history"][0];
    	console.log("purchaseHistory: "+purchaseHistory);
    	if (purchaseHistory !== null) {
    		const unitPrice = purchaseHistory["price"];
	    	const harvestedName = purchaseHistory["harvested_name"];
	    	var purchaseDateString = purchaseHistory["purchase_date"];
	    	if (purchaseDateString === "") {
	    		purchaseDateString = purchaseHistory["recorded_at"];
	    	}

	    	// get quantity. could be stored at various locations in json depending on store
	    	var quantity = 0;
			if (purchaseHistory["quantity"] !== 0) {
	    		quantity = purchaseHistory["quantity"];
	    	} else if (productDetails !== null ) {
	    			if (productDetails["quantity"] !== null && productDetails["quantity"] !== 0 ){
	    			    quantity = productDetails["quantity"];
	       			} else if (productDetails["ingredients_count"] !== null && productDetails["ingredients_count"] !== 0) {
	    				quantity = productDetails["ingredients_count"];
	    			}
	    		}
		  	console.log("Quantity: "+quantity);
	    	console.log("unitPrice: "+unitPrice);
	    	console.log("productID: "+productID);
	    	console.log("harvestedName: "+harvestedName);
	    	console.log("purchaseDateString: "+purchaseDateString);

	    	ref.child('Users/'+user_id+'/FoodItems/'+name).update({
				 	"Quantity":quantity,
				 	"AddedDate":purchaseDateString,
				 	"UnitPrice":unitPrice,
				 	"HarvestedName":harvestedName,
				  });
    	}

    	const productDetails = purchasedItem["product_details"];
    	if (productDetails !== null) {
    		const category = productDetails["category"];
    		const description = productDetails["description"];
    		const largeImageURL = productDetails["large_image"];
    		const sizeInfo = productDetails["size_info"];
    		const size = sizeInfo["size"];
    		const sizeUOM = sizeInfo["size_uom"];
    		const packageCount = sizeInfo["package_count"];
    		const packageCountUOM = sizeInfo["package_count_uom"];
    		// TODO save to firebase
    		ref.child('Users/'+user_id+'/FoodItems/'+name).update({
			 	"ProductDetails":productDetails,
			 	"Category":category,
			 	"Description": description,
			 	"size":size,
			 	"sizeUOM": sizeUOM,
			 	"packageCount":packageCount,
			 	"packageCountUOM": packageCountUOM,
			 	"largeImage": largeImageURL,
			  });
    	} 
    	return;
	});
}

function parseData(data){

	/* 
		* param 'data' should be passed in as a js dictionary
		* you just parse this with brackets
		* there are a couple of examples below
	*/

	let user_store_id = data["user_store_id"];
	let user_id = data["user_id"];
	console.log("user_store_id: ",user_store_id);
	console.log("user_id: ", user_id);

	const userRefPromise = ref.child('users/'+user_id+'/fcmToken').once('value').then(function(snapshot) {
	  // var username = (snapshot.val() && snapshot.val().username) || 'Anonymous';
	  	console.log(snapshot);
	  	const fcmToken = (snapshot.val());
	  	const text = "Your kitchen was just updated with recent purchases! Check it out!";
		const senderName = user_id;
		const payload = {
		notification: {

			title :senderName,
			body: text,
			badge:'7',
			sound:'default',}
		};

		sendPushNotification( fcmToken, payload);
		return;
	});
}
