const functions = require('firebase-functions');
const admin = require('firebase-admin');
// var express = require('express');
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
admin.initializeApp(functions.config().firebase);

const ref = admin.database().ref();

const ALPHA_BASE_URL = "https://www.alphavantage.co/query?";
const ALPHA_TOKEN = "L8VMANDUA7QCW1AU";
const IEX_BASE_URL = 'https://cloud.iexapis.com/stable/';
const IEX_PUBLISHABLE_TOKEN = '&token=pk_2e757120039d401bb9f97f2d037c5a62';
function guid() {
  function s4() {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }
  return s4() + s4() + '-' + s4() + s4();
}

function getCurrDate(){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	return mm+'_'+dd+'_'+yyyy
}

function getDateForMessage(){
	var today = new Date();
	let dd = today.getDate();
	let mm = today.getMonth()+1; //January is 0!
	let yyyy = today.getFullYear();
	let hr = today.getHours();
	const mn = today.getMinutes();
	const ss = today.getSeconds();

	// if (hr < 7){
	// 	hr += 17
	// 	if (dd === 1){
	// 		if(mm === 1){
	// 			yyyy -= 1
	// 			mm = 13
	// 		}
	// 		mm -= 1
	// 		if(mm === 2){
	// 			dd = 28;
	// 		}else if(mm === 4 || mm === 6 || mm === 9 || mm ===11){
	// 			dd = 30;
	// 		}else{
	// 			dd = 31
	// 		}
	// 	}else{
	// 		dd -= 1
	// 	}
	// }else{
	// 	hr -= 7
	// }
	console.log("AAAHHHHHHH")
	console.log((dd).toString())
	console.log((dd).toString().length)
	if((dd).toString().length === 1){
		dd = '0'+(dd).toString()
	}

	return yyyy+'-'+mm+'-'+dd+' '+hr+':'+mn+':'+ss
}

function portValForCalcLeagues(snapshot){
	let val = 0

	Object.keys(snapshot['member_balances']).forEach(userID => {
		val += snapshot['member_balances'][userID]
	});

	Object.keys(snapshot['portfolio_values']).forEach(userID => {
		val += snapshot['portfolio_values'][userID]
	});
	return val
}

function getOneDay(portfolio){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if (dd === 1){
		if(mm === 1){
			yyyy -= 1
			mm = 13
		}
		mm -= 1
		if(mm === 2){
			dd = 28;
		}else if(mm === 4 || mm === 6 || mm === 9 || mm ===11){
			dd = 30;
		}else{
			dd = 31
		}
	}else{
		dd -= 1
	}

	let oneDay = null

	if((dd).toString().length === 1){
		oneDay = mm.toString()+'_'+'0'+(dd).toString()+'_'+yyyy.toString()
	}else{
		oneDay = mm.toString()+'_'+(dd).toString()+'_'+yyyy.toString()
	}
	// console.log(typeof portfolio)
	// console.log(portfolio)
	console.log('oneDay:', oneDay)
	// console.log('******************', Object.keys(portfolio))
	if('snapshots' in portfolio && oneDay in portfolio['snapshots']){
		console.log('oneDay:', oneDay)
		return portValForCalcLeagues(portfolio['snapshots'][oneDay]);
	}else{
		console.log('LOOK AT MEEEEEEEEEE IM MR MEESEEKS!!! ONEDAY')
		console.log(Object.keys(portfolio['snapshots'])[Object.keys(portfolio['snapshots']).length-1])
		console.log(portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]]))
		return portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[Object.keys(portfolio['snapshots']).length-1]])
	}
}

function getOneWeek(portfolio){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if (dd <= 7){
		if(mm === 1){
			yyyy -= 1
			mm = 13
		}
		mm -= 1
		if(mm === 2){
			dd += 21;
		}else if(mm === 4 || mm === 6 || mm === 9 || mm === 11){
			dd += 23;
		}else{
			dd += 24;
		}
	}else{
		dd -= 7
	}

	let oneWeek = null

	if((dd).toString().length === 1){
		oneWeek = mm.toString()+'_'+'0'+(dd).toString()+'_'+yyyy.toString()
	}else{
		oneWeek = mm.toString()+'_'+(dd).toString()+'_'+yyyy.toString()
	}

	console.log('oneWeek:', oneWeek)

	if('snapshots' in portfolio && oneWeek in portfolio['snapshots']){
		console.log('oneWeek:', oneWeek)
		return portValForCalcLeagues(portfolio['snapshots'][oneWeek]);
	}else{
		console.log('LOOK AT MEEEEEEEEEE IM MR MEESEEKS!!! ONE_WEEK')
		console.log(Object.keys(portfolio['snapshots'])[0])
		console.log(portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]]))
		return portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]])
	}
}

function getOneMonth(portfolio){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	if (mm === 1){
		mm = 12;
		yyyy -= 1;
	}else{
		mm -=1
	}

	let oneMonth = null

	if((dd).toString().length === 1){
		oneMonth = mm.toString()+'_'+'0'+(dd).toString()+'_'+yyyy.toString()
	}else{
		oneMonth = mm.toString()+'_'+(dd).toString()+'_'+yyyy.toString()
	}

	if('snapshots' in portfolio && oneMonth in portfolio['snapshots']){
		console.log('oneMonth:', oneMonth)
		return portValForCalcLeagues(portfolio['snapshots'][oneMonth]);
	}else{
		console.log('LOOK AT MEEEEEEEEEE IM MR MEESEEKS!!! ONE_MONTH')
		console.log(Object.keys(portfolio['snapshots'])[0])
		console.log(portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]]))
		return portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]])
	}
}

function getOneYear(portfolio){
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();

	let oneYear = null;

	if((dd).toString().length === 1){
		oneYear = mm.toString()+'_'+'0'+(dd).toString()+'_'+yyyy.toString()-1;
	}else{
		oneYear = mm.toString()+'_'+(dd).toString()+'_'+yyyy.toString()-1;
	}

	console.log('oneYear:', oneYear)
	if('snapshots' in portfolio && oneYear in portfolio['snapshots']){
		console.log('oneYear:', oneYear)
		return portValForCalcLeagues(portfolio['snapshots'][oneYear]);
	}else{
		console.log('LOOK AT MEEEEEEEEEE IM MR MEESEEKS!!! ONE_YEAR')
		console.log(Object.keys(portfolio['snapshots'])[0])
		console.log(portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]]))
		return portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]])
	}
}

function getOverall(portfolio){
	return portValForCalcLeagues(portfolio['snapshots'][Object.keys(portfolio['snapshots'])[0]])
	// padding 
}

// Returns a Promise(HTML page from URL)
function fetchRequest(url) {
    return new Promise((resolve, reject) => {
		const xhr = new XMLHttpRequest();
		xhr.open("GET", url, true);
		xhr.onload = () => resolve(xhr.responseText);
		// xhr.onerror = () => reject("AAAAHHHHHHAHAHAHAHA");
		xhr.send();
    });
}

function aggregateUserPortfolio(portfolio){
  // console.log('PORTFOLIO')
  // console.log(portfolio)
	aggregate = {overall: {}};
	curr_price = 0;
	stocks = []
	Object.keys(portfolio).forEach(team => {
		Object.keys(portfolio[team]).forEach(ticker => {
			stocks.push(ticker);
		});
	});

	// if(stocks.length === 0){
	// 	return []
	// }

	console.log("in aggregate portfolio:", stocks)

	// var api = ALPHA_BASE_URL+"function=BATCH_STOCK_QUOTES&symbols="+stocks.join(',')+
	// '&apikey='+ALPHA_TOKEN
	// console.log(api)
	const api = IEX_BASE_URL+'stock/market/batch?symbols='+stocks.join(',')+'&types=quote'+IEX_PUBLISHABLE_TOKEN;
	console.log(api)
	// return
	// return new Promise((resolve, reject) => {


	return fetchRequest(api).then((data) => {
		return JSON.parse(data)

    }).then(quotes => {
    	console.log("quotes, first ticker:", Object.keys(quotes)[0]);
    	stock_values = {}
    	if('error' in quotes){
    		console.log('IT WORKED CORRECTLY')
    		quotes = {}
    	}
    	for(ticker in quotes){
    		// console.log('***********', ticker, quote)
    		ticker = ticker.toLowerCase();
    		price = quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice']
    		if (price === 0 || price === null){
    			price = quotes[ticker.toUpperCase()]['quote']['latestPrice']
    		}
    		stock_values[ticker] = price;
    	}
    	console.log(stock_values)
    	aggregate['overall'] = {}
  		Object.keys(portfolio).forEach(team => {
  			aggregate[team] = {}
        // console.log("above keys for team")
        // console.log(Object.keys(portfolio[team]))
  			Object.keys(portfolio[team]).forEach(ticker => {
  				curr_price = stock_values[ticker];
  				quantity = 0;
  				Object.keys(portfolio[team][ticker]).forEach(transaction => {
  					entry = portfolio[team][ticker][transaction]
  					// val += entry['quantity']*entry['value'];
  					quantity += entry['quantity'];
  				});
  				console.log('price for ticker =', ticker, curr_price)
				val = quantity*curr_price;
				//We should not be returning a stock if the user no longer owns it, fix here or in MissionControl which passes the argument here
				if(val !== 0){
					aggregate[team][ticker] = {total_value: val, quantity: quantity, changePercent: quotes[ticker.toUpperCase()]['quote']['changePercent']}
				
	  				// aggregate[team][ticker].push(quotes[ticker.toUpperCase()]['quote']['changePercent'])
	  				if(ticker in aggregate['overall']){
	  					aggregate['overall'][ticker]['quantity'] += quantity;
	  					aggregate['overall'][ticker]['total_value'] += val;
	  				}else{
	  					console.log('adding', ticker, 'to db:', {total_value: val, quantity: quantity})
	  					aggregate['overall'][ticker] = {total_value: val, quantity: quantity}
	  				}
	  			}
  			});
  		});
		  console.log('AGGREGATING')
		  // console.log(portfolio)
		  console.log(aggregate)
		  return aggregate;
   	});
}

function calculateSingleTeamUserPortfolio(userID, stocks){
	// let transactions = {}
	value = 0;
	if(stocks===null || stocks === undefined){
		return []
	}
	console.log("STOCKS in calculateSingleTeamUserPortfolio", stocks)
	Object.keys(stocks).forEach(ticker => {
		Object.keys(stocks[ticker]).forEach(transaction => {
			if(!(stocks[ticker][transaction]['sold_by'] === userID ||
				stocks[ticker][transaction]['purchased_by'] === userID)){
				console.log(stocks[ticker][transaction]);
				delete stocks[ticker][transaction];
			}
		});
		console.log("ASDASF", ticker, stocks[ticker], Object.keys(stocks[ticker]).length);
		if (Object.keys(stocks[ticker]).length === 0){
			console.log('deleting entry for', ticker)
			console.log(Object.keys(stocks[ticker]).length)
			console.log(Object.keys(stocks[ticker]))
			delete stocks[ticker]
		}
	});
	console.log("stocks in calculateSingleTeamUserPortfolio", stocks);
	return stocks;
}

function calculateTotalPortfolioInvestment(portfolio){
	const stocks = []
	var stock_dict = {}
	var inv = 0;
	if(!portfolio || !portfolio['stocks']){
		console.log('portfolio is null');
	}else{
		Object.keys(portfolio['stocks']).forEach(key => {
	    	// console.log(portfolio['stocks'][key])
	      	stocks.push(key)
	      	stock_dict[key] = 0;
	    	Object.keys(portfolio['stocks'][key]).forEach(k => {
	    		entry = portfolio['stocks'][key][k];
	    		// console.log(entry);
	    		inv += entry["quantity"] * entry['value']
	    		stock_dict[key] += entry["quantity"]
	    		// console.log(inv)
	       	});
	    });
	}
    return [inv, stocks, stock_dict];
}

function howMuchStockDoIHave(user, portfolio){
	var amount = 0;
	console.log("checking how much stock i have")
	console.log(portfolio)
	if(portfolio){
		Object.keys(portfolio['stocks']).forEach(ticker => {
			Object.keys(portfolio['stocks'][ticker]).forEach(date => {
				if ( portfolio['stocks'][ticker][date]['purchased_by'] === user){
					amount += portfolio['stocks'][ticker][date]['quantity'];
				}
				if (portfolio['stocks'][ticker][date]['sold_by'] === user){
					amount += portfolio['stocks'][ticker][date]['quantity'];
				}

			});
		});
	}
	return amount;
}

function calculatePortfolioValue(portfolio, member_balances){
	// console.log(api);
	const portVal = calculateTotalPortfolioInvestment(portfolio);
	// var investment = portVal[0];
	var stocks = portVal[1];
	var stock_dict = portVal[2];
	var curr_val = 0;



	// const api = ALPHA_BASE_URL+"function=BATCH_STOCK_QUOTES&symbols="+stocks.join(',')+
	// '&apikey='+ALPHA_TOKEN
	const api = IEX_BASE_URL+'stock/market/batch?symbols='+stocks.join(',')+'&types=quote'+IEX_PUBLISHABLE_TOKEN;
	console.log(api);

	if(stocks.length === 0){
		return
	}


	return new Promise((resolve, reject) => {


		return fetchRequest(api).then((data) => {
			var quotes = JSON.parse(data)
			// // console.log(quotes);
			// for(var i=0; i<quotes.length; i++){
			// 	const symbol = quotes[i]['1. symbol'].toLowerCase();
			// 	const curr_price = quotes[i]['2. price'];
			// 	const timestamp = quotes[i]['4. timestamp'];
			// 	console.log(curr_price, symbol, stock_dict[symbol])
			// 	curr_val += curr_price * stock_dict[symbol]
			// 	// console.log(quotes[i]['1. symbol'].toLowerCase())
			// }
			for(ticker in quotes){
				console.log("WTF", ticker)
				ticker = ticker.toLowerCase();
    			price = quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice']
    			if (price === 0 || price === null){
    				price = quotes[ticker.toUpperCase()]['quote']['latestPrice']
    			}
    			// console.log(quotes[ticker.toUpperCase()]['quote'])
    			console.log('TICKER AND PRICE', ticker, quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice'])
				// ticker = ticker.toLowerCase();
				// price = quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice']
				curr_val += price * stock_dict[ticker]
			}

			Object.keys(member_balances).forEach(balance => {
				console.log('***************')
				console.log(balance, member_balances[balance])
				curr_val += member_balances[balance]
			});

			// console.log("curr_val = "+curr_val.toString());

			// console.log("total_gain = "+ (total_gain).toString());
			// console.log(quotes[0]);
			console.log('currval,', curr_val)
			resolve( curr_val );
			return
		});

    });
}

function getTeamPortfolioValue(teamID, response){
	const teamRef = ref.child('teams/'+teamID);
	// const teamName = ref.child('teams/'+teamID+'/teamName').val();
	// const portfolioRef = teamRef.child('portfolio');

	// console.log("ASDFASDF: " + teamName.key+ " " + portfolioRef.key)
	var teamName = ''
	var portfolio
	var return_val = null;
	var member_balances = null;
	return teamRef.once('value').then(snap => {
		console.log("ASDFKASDKFASDLKFAJKS", teamID);
		console.log(snap.val());
		if(!snap.child("teamName").val()){
			console.log("Adam added a team that he was not supposed to");
			console.log('The team ID is:', teamID);
			response.status(400).send("You have an unauthorized team in your league");
			return
		}
		teamName = snap.child("teamName").val().toString();
		member_balances = snap.child('member_balances').val();
		console.log("HELLO: "+snap.key+ " " + teamName);
		portfolio = snap.child('portfolio').val();
		if(!snap.hasChild('portfolio/snapshots')){
			console.log('THERE IS NO PORTFOLIO')
			return_val = {
				[teamID]:
						{
						    'dayIncrease': 		null,
						    'weekIncrease': 	null,
						    'monthIncrease': 	null,
						    'yearlyIncrease': 	null,
						    'overallIncrease': 	null,
						    'teamName': 		teamName,
						    'teamID': 			teamID
						}
					}
			return false
		}
		console.log("portfolio!", portfolio);
		return true
	}).then( valuesExist => {
	    var portfolioVal = 0;
	    // console.log("BLBLBLLADLSGALSDFKASDFLASLDF "+teamName);
	    const portfolioValPromise = calculatePortfolioValue(portfolio, member_balances)
	    return portfolioValPromise
	}).then(total_val => {

		// const teamName = ref.child('teams/'+teamID+'/teamName').val().toString();
		if(return_val){
			return return_val;
		}

    	var s = teamID.toString()

		var today = new Date();
		var dd = today.getDate();
		var mm = today.getMonth()+1; //January is 0!
		var yyyy = today.getFullYear();

		// console.log("ASDFASDFASDFASDFASDFASDF");
		// console.log(portfolio[mm.toString()+'_'+(dd-1).toString()+'_'+yyyy.toString()]/total_val);
		console.log("TODAY IS:")
		getOneDay(portfolio)
		getOneWeek(portfolio)
		getOneMonth(portfolio)
		getOneYear(portfolio)
		getOverall(portfolio)
		// console.log(mm.toString()+'_'+'0'+(dd).toString()+'_'+yyyy.toString())
    	var oneDay = getOneDay(portfolio);
    	var sevenDay = getOneWeek(portfolio);
    	var thirtyDay = getOneMonth(portfolio);
    	var year = getOneYear(portfolio);

	   	var original = getOverall(portfolio);
	   	console.log('THERE ARE VALS SUPPOSEDLY')
	   	// console.log("FUCKING RIP")
	   	console.log(oneDay, sevenDay, thirtyDay, year, total_val)

	    return {
	    	[s]:
	    	{
	    		'teamBalance': 		Math.round(total_val * 1e4) / 1e4,
			    'dayIncrease': 		Math.round(((total_val-oneDay)/oneDay) * 1e4) / 1e4,
			    'weekIncrease': 	Math.round(((total_val-sevenDay)/sevenDay) * 1e4) / 1e4,
			    'monthIncrease': 	Math.round(((total_val-thirtyDay)/thirtyDay) * 1e4) / 1e4,
			    'yearlyIncrease': 	Math.round(((total_val-year)/year) * 1e4) / 1e4,
			    'overallIncrease': 	Math.round(((total_val-original)/original) * 1e4) / 1e4,
			    'teamName': 		teamName,
			    'teamID': 			s
			}
		}
    });
}

function calcLeagueValues(response, leagueID='00000'){

	const leagueRef = ref.child('leagues/'+leagueID);
	teamVals = [];
	return leagueRef.once('value').then(snap => {
		return snap.child('teams').val()

	}).then(teams => {
		Object.keys(teams).forEach(teamID => {
			var teamValPromise = getTeamPortfolioValue(teamID, response);
		    // var t = teamID.toString();
		    // temp = {t: teamValPromise};
		    console.log("COLLECTING RESPONSES")
		    console.log("length of teamVals", teamVals.length)
		    teamVals.push( teamValPromise );

		});
    	return Promise.all(teamVals).then((values) =>{
		    console.log(" calcLeagueValues" , values);
			response.send(values);
			return
    	});
	});
}

function getCondensedPortfolios(){
	const teamsRef = ref.child('teams');
	var ret = [{}, []];
	// ret.push({});
	// ret.push([]);
	return teamsRef.once('value').then(snap => {
		var portfolios = [];
		snap.forEach(team => {
			// portfolios.push();
			const teamID = team.key;
			// console.log(teamID);
			ret[0][teamID] = {};
			ret[0][teamID]['member_balances'] = snap.child(teamID+'/member_balances').val();
			// console.log(team)
			if(team.hasChild('portfolio/stocks')){
				const stock_dict = team.child('portfolio/stocks').val();
				console.log(team.child('portfolio'))
				console.log(team.child('teamName').val())
				console.log(stock_dict);
				Object.keys(stock_dict).forEach(ticker => {
					if(!ret[1].includes(ticker)){ ret[1].push(ticker) }

					ret[0][teamID][ticker] = 0;
					Object.keys(stock_dict[ticker]).forEach(key1 => {
						ret[0][teamID][ticker] += stock_dict[ticker][key1]['quantity']
						console.log(ticker, stock_dict[ticker][key1]['quantity']);

					});
	    			// console.log(key, "&&&&*&&***&");
	    			// console.log(stock_dict[key]);
				});
			}
		});
		// console.log("***********************");
		// console.log(ret[0]);
		return ret;
	});
}

function calculateTeamPortfolioValue(team, quotes){
	console.log("****************************");
	var val = 0;
	Object.keys(team).forEach(ticker => {
		if(ticker !== 'member_balances'){
			console.log(team[ticker], quotes[ticker])
			val += team[ticker] * quotes[ticker]
		}
	});

	Object.keys(team['member_balances']).forEach(balance => {
		console.log(balance, team['member_balances'][balance])
		val += team['member_balances'][balance]
	});

	// console.log(team, val);
	return Math.round(val * 1e2) / 1e2;
}

function updatePortfolios(response){
	// var today = new Date();
	// var dd = today.getDate();
	// var mm = today.getMonth()+1; //January is 0!
	// var yyyy = today.getFullYear();

	const curr_day = getCurrDate();

	return getCondensedPortfolios().then(return_val => {
		const portfolios = return_val[0];
		const stocks = return_val[1];
		// const member_balances = return_val[0][]
		console.log(portfolios);
		console.log('************************')
		console.log(stocks)

		const api = IEX_BASE_URL+'stock/market/batch?symbols='+stocks.join(',')+'&types=quote'+IEX_PUBLISHABLE_TOKEN;
		console.log(api);

		return fetchRequest(api).then((data) => {
			var quotes = JSON.parse(data)
			var processedQuotes = {}
			vals = []

			for(ticker in quotes){
				ticker = ticker.toLowerCase()
				price = quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice']
				if (price === 0 || price === null){
    				price = quotes[ticker.toUpperCase()]['quote']['latestPrice']
    			}
				processedQuotes[ticker] = price;
			}
			console.log(processedQuotes);

			Object.keys(portfolios).forEach(teamID => {
				val = calculateTeamPortfolioValue(portfolios[teamID], processedQuotes);
				console.log(teamID, curr_day, val)
				vals.push([teamID, val])
				portRef = ref.child('teams/'+teamID+'/portfolio/')
				portRef.child(curr_day).set(val);
			});


			return vals
		}).then(vals => {
			response.status(200).send(vals);
			return
		});
	});
}

function pushStockPurchaseToDatabase(ticker, amount, price, user, teamID, response, buy=true){
	const portfolioRef = ref.child('teams/'+teamID+'/portfolio');
	const userRef = ref.child('users/'+user);
	const teamRef = ref.child('teams/'+teamID);

	console.log(ticker, amount, price, user, teamID);
	amount = parseInt(amount, 10)
	price = parseFloat(price.replace(",",""));
	let userVal = -1;

	// var canTransact = true

	return teamRef.once('value').then(snap => {
		userVal = snap.child('member_balances/'+user).val();
		const curr_day = getCurrDate();
		console.log(snap.val());
		console.log(snap.child('member_balances').val())
		console.log('teamID', teamID);
		console.log(user)
		if(userVal < amount*price && buy){
			console.log("TRYING TO BUY STOCK BUT DID NOT HAVE ENOUGH MONEY");
			console.log('userVal:', userVal, 'amount*price', amount*price);
			response.status(400).send("You do not have enough cash for this purchase")
			return false
			// canTransact = false
		}else if (!buy && howMuchStockDoIHave(user, snap.child('portfolio').val()) < amount) {
			response.status(400).send('You do not have enough stocks to make this sale.')
			return false
			// canTransact = false
		}else {
			if(snap.hasChild('portfolio/stocks')){
				console.log('there is stuff in portfolio')
				// if(snap.hasChild('portfolio/stocks/'+ticker)){
				if(buy){
					teamRef.child('portfolio/stocks/'+ticker).push({
						purchase_date: curr_day,
						purchased_by: user,
						quantity: amount,
						value: price
					});
				}else{
					amount = -amount
					teamRef.child('portfolio/stocks/'+ticker).push({
						sell_date : curr_day,
						sold_by: user,
						quantity: amount,
						value: price
					});
				}
				// }
			}else{
				teamRef.child('portfolio/stocks').set({
					[ticker]: {
						[guid()] : {
							purchase_date: curr_day,
							purchased_by: user,
							quantity: amount,
							value: price
						}
					}
				});
				// response.status(200).send('success')
			}
			response.status(200).send('success')
			return true
		}


	}).then(tradeExecuted => {
		if(tradeExecuted){
			const newVal = Math.round((userVal-price*amount) * 1e2) / 1e2;
			teamRef.child('member_balances/'+user).set(newVal);
			userRef.child('team_balances/'+teamID).set(newVal);

			const listRef = ref.child('purchasedStockList');
			return listRef.once('value').then(snap => {
				found = false;
				Object.keys(snap.val()).forEach(key => {
					if (key === ticker){
						val = snap.child(key).val();
						listRef.child(key).set(val+amount);
						found = true;
					}
				});
				if(!found){
					listRef.update({[ticker]: amount});
				}
			return snap.val()
			});
		}
		return
	}).catch((err) => {
		console.log(err);
	});
}

function aggregateSingleUserTeamPortfolio(portfolio){
	//TODO TODO TODO
	//this portfolio is a single user's which is associated with a single team
}

function addNotificationToUser(params, response=null){
	if(params['type'] === 'invite'){
		let inviterName = params['inviterName'];
		let inviterID = params['inviterID'];
		let invitedID = params['invitedID'];

		let invMessage = inviterName +' has invited you to join their team \'' + params['teamName'] + '\'. Click here to accept.';
		let currDate = getCurrDate();
		payload = {
			type: params['type'],
			message: invMessage,
			image: params['image'],
			time: currDate,
			team: params['team']
		}

		ref.child('users/'+invitedID+'/notifications').push(payload)
		response.status(200).send({teamID: params['team'], teamName: params['teamName']})
		// response.status(200).send('Notification Added')
		return
	}else if(params['type'] === 'welcome'){
		payload = {
			type: params['type'],
			message: params['message'],
			time: getCurrDate(),
			image: 'https://firebasestorage.googleapis.com/v0/b/hedge-beta.appspot.com/o/hedgeLogo%403x.png?alt=media&token=0cc4cef2-44c1-41a4-8da4-a2a56e8754e7'
		}

		ref.child('users/'+params['userID']+'/notifications').push(payload)
		return
	}
	response.status(400).send({Error: 'Error'})
	return
}

exports.leagueValues = functions.https.onRequest((request, response) => {
	calcLeagueValues(response, request.query.leagueID);
});

exports.updatePortfolioValues = functions.https.onRequest((request, response) => {
	updatePortfolios(response);
});

exports.transferStocks = functions.https.onRequest((request, response) => {
	// console.log(request.query);
	// var query = { ticker: 'aapl', amount: '5', price: '100', user: '123', team: '01234' };

	var ticker = null;
    var amount = null;
    var price = null;
    var user = null;
    var team = null;
    var league = null;
    var buy = null;
    var willBuy = false;
    var willSell = false;
    //ticker=<STOCK TICKER>&amount=<AMOUNT>&price=<BUY PRICE>&
    //user=<USER [ID|NAME]>&team=<TEAM_ID>&league=<LEAGUE ID>&buy=[true|false]

    try {
    	//TODO uncomment below here and test
		ticker = request.query.ticker.toLowerCase();
		amount = request.query.amount;
		price = request.query.price;
		user = request.query.user;
		team = request.query.team;
		if(typeof team !== 'string'){
			team = team.toString();
		}
		league = request.query.league;
		buy = request.query.buy.toLowerCase();

		if(buy !== null && buy === 'true'){
			willBuy = true;
		}else{
			willSell = true;
		}




    } catch (err) {
		console.log("Parameters not passed in properly");
		console.log(ticker, amount, price, user, team)
		response.status(400).send();
		return;
    }
	console.log(ticker, amount, price, user, team, willBuy);
    return pushStockPurchaseToDatabase(ticker, amount, price, user, team, response, willBuy)
});

exports.userPortfolio = functions.https.onRequest((request, response) => {
	let userID = request.query.userID;
	if(typeof userID === 'undefined'){
		userID = request.query.user;
	}
	// const userID = 'SHdliK0oTfhAW0uPWB9RNDoOHz03'
	const userRef = ref.child('users/'+userID);
	const teamsRef = ref.child('teams');
	console.log('userID', userID);
	// response.status(200).send('test');
	return userRef.once('value').then( snap => {
		return snap.val();
	}).then( teams => {
		console.log("TEAMS", teams)
		console.log("teams in userPortfolio =", teams['teamIDs'])
		if(typeof teams['teamIDs'] === "undefined"){
			return []
		}
		// console.log(teams[0])
		return teamsRef.once('value').then( snap => {
			let arr = {};
			// console.log("what is this value", typeof teams['teamIDs'], teams['teamIDs']);
			if(Object.keys(teams['teamIDs']).length > 0){
				Object.keys(teams['teamIDs']).forEach(key => {
					console.log("TEAMNAME line 549", key);
					// console.log(snap.child(key+'/portfolio/stocks').val());
					console.log(calculateSingleTeamUserPortfolio(userID, snap.child(key+'/portfolio/stocks').val()));
					arr[key] = calculateSingleTeamUserPortfolio(userID, snap.child(key+'/portfolio/stocks').val());
					console.log("**************", key)
					// console.log(arr[key])
				});
			}
			return arr;
		});

		//for each team in teams
		//	get the portfolio value of the team
		//	calculateSingleTeamPortfolio(userID, team)
		//	team name: value
		//at the end, aggregate all the values
		//return the dict
	}).then(arr => {
		return aggregateUserPortfolio(arr).then( ret_value => {
			response.status(200).send(ret_value);
			return
		});
		// console.log(aggregateUserPortfolio(arr));
		// console.log(arr);

	}).catch((err) => {
		console.log(err);
	});
});

exports.userExists = functions.https.onRequest((request, response) => {
	let userID = request.query.user;
	const userRef = ref.child('users/'+userID);
	// console.log(typeof userRef);

	return userRef.once('value').then(snap => {

		if(snap.val() === null){
			response.status(200).send('False')
		}else{
			response.status(200).send('True')
		}
		return
	});
});

exports.getMoney = functions.https.onRequest((request, response) => {
	const userID = request.query.userID;
	const teamID = request.query.teamID;

	const user_money = ref.child('teams/'+teamID+'/member_balances/'+userID);
	console.log('teams/'+teamID+'/member_balances/'+userID)

	return user_money.once('value').then(snap => {
		console.log('This is how much cash the user has available', snap.val());
		response.status(200).send(snap.val().toString());
		return
	});
});

exports.sendTeamInvite = functions.https.onRequest((request, response) => {

	const inviterID = request.query.inviterID;
	const invitedID = request.query.invitedID;
	const image = request.query.imageString;
	const type = request.query.type;
	const team = request.query.team;
	const userRefPromise = ref.child('users/'+inviterID+'/username').once('value');
	const teamRefPromise = ref.child('teams/'+team+'/teamName').once('value');
	let params = {}
	params['inviterID'] = inviterID;
	params['invitedID'] = invitedID;
	params['image'] = image;
	params['team'] = team;
	params['type'] = type;



	return Promise.all([userRefPromise, teamRefPromise]).then(results => {
		console.log('inviterName:', results[0].val(), inviterID);
		console.log('teamName:', results[1].val());
		console.log('invited:', invitedID);
		params['inviterName'] = results[0].val();
		params['teamName'] = results[1].val();
		addNotificationToUser(params, response)
		return
	});
	// TODO get the inviter username
});

exports.getDate = functions.https.onRequest((request, response) => {
	var today = new Date();
	var dd = today.getDate();
	var mm = today.getMonth()+1; //January is 0!
	var yyyy = today.getFullYear();
	var hh = today.getHours();
	var mins = today.getMinutes()
	response.status(200).send({dd: dd, mm: mm, yyyy: yyyy, hh: hh, mins: mins})
});

exports.addNotification = functions.https.onRequest((request, response) => {
	const userID = request.query.userID;
	const notificationType = request.query.type;
	const messageText = request.query.messge;

	const userRef = ref.child('users/'+userID);
	userRef.child('notifications').update({
		type: notificationType,
		text: messageText
	});
	response.status(200).send('Notification Added')

	// return userRef.once('value').then(userSnap => {

	// });
});

exports.userTeams = functions.https.onRequest((request, response) => {
	const userID = request.query.userID;
	const userTeamsRef = ref.child('users/'+userID+'/teamIDs')
	let teams = []

	return userTeamsRef.once('value').then( snap => {
		// console.log(snap.val());
		teams = Object.keys(snap.val());
		// response.status(200).send(snap.val());
		return

	}).then(() => {
		const teamsRef = ref.child('teams').once('value').then(snap =>{
			return snap.val();
		}).then(teamVal => {
			let retValue = {}
			console.log(typeof teams, teams)
			console.log(teamVal)
			Object.keys(teamVal).forEach(teamID => {
				if (teams.indexOf(teamID) > -1) {
				    console.log("FOUND IT!", teamID)
				    console.log(teamVal[teamID])
				    retValue[teamID] = teamVal[teamID]
				} else {
				    console.log("NOP")
				}
			});
			response.status(200).send(retValue);
			return

		});
		// response.status(400).send('some error');
		return
	});
});

exports.userHasStock = functions.https.onRequest((request, response) => {
	const userID = request.query.userID;
	const ticker = request.query.ticker.toLowerCase();
	let hasStock = false;

	//Get the teams of the users, the returned user teams are passed to the next promise as user_teams
	return ref.child('users/'+userID).once('value').then(snap => {
		teams = snap.child('teamIDs').val()
		console.log(Object.keys(teams), teams[Object.keys(teams)[0]])
		return teams
	}).then(user_teams => {
		//Get the value of all teams in the database
		return ref.child('teams').once('value').then(snap =>{
			let allTeams = snap.val()
			//Create return object
			let teamsDict = {'teams': [], 'isOwned': false}
			//For each team the user has
			Object.keys(user_teams).forEach(teamID => {
				//If a user's team has a portfolio and that portfolio has stocks
				if('portfolio' in allTeams[teamID] && 'stocks' in allTeams[teamID]['portfolio']){
					//Grab the portfolio for a given user team
					let p = allTeams[teamID]['portfolio']['stocks'];
					console.log('THERE IS A PORTFOLIO AND STOCKS AND STUFFS')
					/*
					For each stock in the portfolio see if it's the query stock AND if the user purchased it 
					Tickers are unique child nodes in a portfolio
					*/
					let quantityOwned = 0
					/*
					The purpose of this loop is to check for ownership and aggregate the quantity owned
					Regardless of if the user owns it or not a team must be returned so that users can select from which team to take an action (buy/sell)
					Checking for quantities occurs on the client
					*/
					Object.keys(p).forEach(curr_ticker => {
						// console.log('in loop')
						// console.log(curr_ticker)
						// console.log(ticker)
						//If the stock in the portfolio is the one the client querried ownership for
						if(curr_ticker === ticker){
							console.log('curr_ticker === ticker')
							let curr_stock_quantity = 0;
							//Aggregate all purchases in that portfolio to get the total value, need the value just for that user
							Object.keys(p[curr_ticker]).forEach(transaction => {
								// console.log('in aggregation loop')
								// console.log(p[curr_ticker][transaction]['purchased_by'])
								// console.log(userID)
								if(p[curr_ticker][transaction]['purchased_by'] === userID){
									curr_stock_quantity += p[curr_ticker][transaction]['quantity']
									console.log('hello', curr_stock_quantity)
								}

								//Consider the case when for that index it is a sale
								if(p[curr_ticker][transaction]['sold_by'] === userID){
									curr_stock_quantity += p[curr_ticker][transaction]['quantity']
									console.log('hello', curr_stock_quantity)
								}
							})
							if(curr_stock_quantity < 0){
								response.status(400).send("There was a fuck-up in the db and someone has negative stocks")
							}
							if(curr_stock_quantity > 0){
								quantityOwned = curr_stock_quantity
								teamsDict['isOwned'] = true;
							}
						}
					})
					teamsDict['teams'].push({
						'teamName': allTeams[teamID]['teamName'],
						'teamID': teamID,
						'quantity': quantityOwned,
						'userBalance': allTeams[teamID]['member_balances'][userID]})
				}else{
					teamsDict['teams'].push({
						'teamName': allTeams[teamID]['teamName'],
						'teamID': teamID,
						'quantity': 0,
						'userBalance': allTeams[teamID]['member_balances'][userID]
					});
				}
			});
			response.status(200).send(teamsDict)
			return
		});

		// Object.keys(teams).forEach(teamID => {
		// 	console.log(teamID, teams[teamID])
		// });

	});
});

exports.seedUserCash = functions.database.ref('teams/{teamID}/members/{memberID}').onCreate( event => {
	dsnap = event.data

	const teamID = event.params.teamID;
	// const newMember = dsnap.val()
	const userID = event.params.memberID
	const teamRef = ref.child('teams/'+teamID);
	const userRef = ref.child('users/'+userID);

	return teamRef.once('value').then(snap => {
		member_name = snap.child(teamID+'/members/'+event.params.memberID).val()
		console.log('asdfkahjsdifhajlfd', member_name, userID)

		if(snap.hasChild('member_balances')){

			teamRef.child('member_balances').update({
				[userID] : 10000
			});

		}else{
			teamRef.update({
				member_balances:
					{ [userID] : 10000 }
			})
		}
		return "success"

	}).then(() => {
		return userRef.once('value').then(snap => {
			if(snap.hasChild('team_balances')){

				userRef.child('team_balances').update({
					[teamID] : 10000
				});

			}else{
				userRef.update({
					team_balances:
						{ [teamID] : 10000 }
				})
			}
			return 'success'
		});
	});
});

exports.teamCreateAddMemberBalances = functions.database.ref('teams/{teamID}').onCreate( event => {
	const teamID = event.params.teamID;
	const teamRef = ref.child('teams/'+teamID);

	return teamRef.child('members').once('value').then(membersSnap => {
		Object.keys(membersSnap.val()).forEach( memberID => {
			teamRef.update({
				member_balances:
					{ [memberID] : 10000 }
			});
		});
		return
	});
});

exports.getAllUsers = functions.https.onRequest((request, response) => {
	const userRef = ref.child('users')

	return userRef.once('value').then(snap => {
		ret_value = {}
		Object.keys(snap.val()).forEach(userID =>{
			console.log(userID, snap.val()[userID]['username'])
			ret_value[userID] = snap.val()[userID]['username']
		});
		response.status(200).send(ret_value)
		return
	});
});

exports.teamMissionControl = functions.https.onRequest((request, response) => {
	return_dictionary = {}
	const userID = request.query.userID;
	// const userRef = ref.child('users/');
	// const teamsRef = ref.child('teams/');

	const getUserPromise = ref.child('users').once('value');
	const teamsPromise = ref.child('teams').once('value');
	const leaguesPromise = ref.child('leagues').once('value');

	return Promise.all([getUserPromise, teamsPromise, leaguesPromise]).then(results => {
		

		userObject = results[0].val();
		// if(userObject[userID]){
		console.log("results user object", userObject);

		const userName = userObject[userID]['username'];
		console.log(userObject[userID]);
		console.log(userObject[userID]['teamIDs']);
		const teamIDs = Object.keys(userObject[userID]['teamIDs']);
		// }
		console.log("results teamIDs object", teamIDs);

		const teamObject = results[1].val();
	 	console.log("results team object", teamObject);

		const leagueIDs = []

		// Object.keys(results[2].val()).forEach(leagueID => {
		// 	if(teamID in Object.keys(results[2].child(leagueID+'/teams').val())){
		// 		leagueIDs.push(results[2].child(leagueID+'/leagueName').val())
		// 	}
		// });
		return_dictionary['teams'] = {}

		return_dictionary['userID'] = userID;
		return_dictionary['userName'] = userName;

		tempPortfolio = {}
		for(let i = 0; i < teamIDs.length; i++){
			t_id = teamIDs[i]
			// console.log(t_id)
			let team = teamObject[t_id]
			let teamMates = {}

			for (key in team['members']){
				if (t_id !== key){
					teamMates[key] = team['members'][key]
				}
			}
			if(Object.keys(teamMates).length === 0){
				teamMates[key] = team['members'][key]
			}

			// console.log(team)
			return_dictionary['teams'][t_id] = {}
			return_dictionary['teams'][t_id]['teamName'] = team['teamName']
			return_dictionary['teams'][t_id]['score'] = team['score']
			return_dictionary['teams'][t_id]['leagueIDs'] = team['leagueIDs']
			return_dictionary['teams'][t_id]['teamID'] = t_id;
			return_dictionary['teams'][t_id]['score'] = 69;
			return_dictionary['teams'][t_id]['teammates'] = teamMates;

			// TODO
			return_dictionary['teams'][t_id]['leagues'] = {'fakeLeague1': 2, 'fakeLeague2': 4}

			console.log(" return_dictionary: ", return_dictionary);
			let s = null
			if(team['portfolio']){
				s = team['portfolio']['stocks']
			}
			console.log("team", team);
			tempPortfolio[t_id] = calculateSingleTeamUserPortfolio(userID, s)
		}

		console.log("temp portfolio: ", tempPortfolio);

		return aggregateUserPortfolio(tempPortfolio).then( portVal => {
			return_dictionary['teams']['overall'] = {}
			Object.keys(portVal).forEach(teamID => {
				// console.log(return_dictionary['teams'])
				// console.log(teamID, return_dictionary['teams'][teamID])
				return_dictionary['teams'][teamID]['teamPortfolio'] = portVal[teamID]
			})
			// return_dictionary['teams'][t_id]['teamPortfolio'] = portVal.val();
			response.status(200).send(return_dictionary);
			return
		});

	}).then(data => {
            console.log('Resolved', data)
            return data;
        })
        .catch(err => {
            console.log('Error inside catch block2', err)
            throw err

        });

	//TODO
	// Need:
	//	Teams - ID, name, score, portolio (specific to this user)
	//team members
	// leagues that team is in, their rank in that league, active challenge
	//
	// userid, username
});

exports.sendPushNotification = functions.database.ref('users/{userID}/notifications/{notificationID}').onWrite((event) => {
	// const notificationID = event.params.notificationID;
	// const userID = event.params.userID;
	const notificationID = '-L74N48kGjUFBRXcbZSB'
	const userID = 'gC43M5SXQLY3DmFqKqH0RjSDPQz2';
	console.log(notificationID)
	const getDeviceTokensPromise = ref.child(`/users/${userID}/notificationTokens`).once('value');
	const notifPromise = ref.child(`/users/${userID}/notifications/${notificationID}`).once('value');

	return Promise.all([getDeviceTokensPromise, notifPromise]).then(results => {
		var tokensSnapshot = results[0];
		var original_notif = results[1].val();
		// console.log()
		console.log(tokensSnapshot.val());
		// console.log(original_notif.toString());
		// console.log(typeof original_notif);
		// console.log(original_notif['text']);

		    // Check if there are any device tokens.
	    if (!tokensSnapshot.hasChildren()) {
	    	return console.log('There are no notification tokens to send to.');
	    }
	    console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
	    console.log('notif_text:', original_notif['text'])
	    // console.log('Fetched follower profile', follower);

		// Notification details.
	    const payload = {
	      notification: {
	        title: 'Stock Performance info',
	        body: original_notif['text']//,
	        // icon: follower.photoURL,
	      },
	    };

	    // Listing all tokens.
   		const tokens = Object.keys(tokensSnapshot.val());
   		console.log(tokens)

   		// Send a message in the dry run mode.
		var dryRun = true;
		admin.messaging().sendToDevice(tokens, payload)
		  .then(response => {
		    // See the MessagingDevicesResponse reference documentation for
		    // the contents of response.
		    console.log('Successfully sent message:', response);
		    console.log(response.results[0].error)
		    return
		  })
		  .catch(error => {
		    console.log('Error sending message:', error);
		    return
		  });
		  return

		// return admin.messaging().sendToDevice(tokens, payload);

	}).then(response => {
		 // For each message check if there was an error.
	    const tokensToRemove = [];
	    // response.results.forEach((result, index) => {
	    //   const error = result.error;
	    //   if (error) {
	    //     console.error('Failure sending notification to', tokens[index], error);
	    //     // Cleanup the tokens who are not registered anymore.
	    //     if (error.code === 'messaging/invalid-registration-token' || error.code === 'messaging/registration-token-not-registered') {
	    //       tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
	    //     }
	    //   }
	    // });
	    return Promise.all(tokensToRemove);
	});
});

exports.isNameUnique = functions.https.onRequest((request, response) => {
	const checkingTeamName = request.query.teamName;
	const checkingUserName = request.query.userName;
	const checkingLeagueName = request.query.leagueName;

	let currRef = null
	let currCheck = null
	let checkName = null
	if(checkingTeamName){
		currRef = ref.child('teams');
		currCheck = 'teamName';
		checkName = checkingTeamName;
	}else if(checkingUserName){
		currRef = ref.child('users')
		currCheck = 'username'
		checkName = checkingUserName;
	}else if(checkingLeagueName){
		currRef = ref.child('leagues')
		currCheck = 'leagueName'
		checkName = checkingLeagueName;
	}
	// const teamRef = ref.child('teams')


	return currRef.once('value').then(snap => {
		currInstances = snap.val();
		var unique = true
		Object.keys(currInstances).forEach(ID => {
			if(currInstances[ID][currCheck].toLowerCase() === checkName.toLowerCase()){
				unique = false
				response.status(200).send(false);
			}
		});
		if(unique){
			response.status(200).send(true);
		}

		return
	});
});

exports.test = functions.https.onRequest((request, response) => {
	// let URL = IEX_BASE_URL+'/stock/market/batch?symbols='+'aapl,fb'+'&types=quote'

	// return fetchRequest(URL).then(data => {
	// 	var quotes = JSON.parse(data)
	// 	console.log(quotes['AAPL']['quote']['latestPrice'])
	// 	response.status(200).send(quotes)
	// 	return
	// });

	d = new Date()
	console.log(d.getDate().toString(), d.getHours().toString(), d.getMinutes().toString())
	console.log("CURRDATE =", getCurrDate())
	response.status(200).send(d.getDate().toString(), d.getHours().toString(), d.getMinutes().toString())
});

exports.addUserToTeam = functions.https.onRequest((request, response) => {
	const teamID = request.query.teamID;
	const userID = request.query.userID;

	const userRefPromise = ref.child('users/'+userID).once('value');
	const teamRefPromise = ref.child('teams/'+teamID).once('value');

	return Promise.all([userRefPromise, teamRefPromise]).then(results => {
		let teamName = results[1].child('teamName').val();
		let userName = results[0].child('username').val();
		console.log({[teamID]: teamName}, results[0].child('teamIDs').val());
		console.log({[userID]: userName}, results[1].child('members').val());
		ref.child('users/'+userID+'/teamIDs').update({[teamID]: teamName})
		ref.child('teams/'+teamID+'/members').update({[userID]: userName})
		// results[0].child('teamIDs').update({[teamID]: teamName})
		// results[1].child('members').update({[userID]: userName})
		response.status(200).send('User added to team')
		return
	});
});

exports.giftStock = functions.https.onRequest((request, response) => {

	const ticker = request.query.ticker.toLowerCase();
	const value = request.query.value;
	// const amount = request.query.amount;
	// // const price = request.query.price;
	const userID = request.query.user;
	// const gifterUserID = request.query.gifter;
	const teamID = request.query.team;

	const api = IEX_BASE_URL+'stock/market/batch?symbols='+ticker+'&types=quote'+IEX_PUBLISHABLE_TOKEN;
	console.log(api);


	return new Promise((resolve, reject) => {

		return fetchRequest(api).then((data) => {
			var quotes = JSON.parse(data)
			// // console.log("WTF", ticker)
			// ticker = ticker.toLowerCase();
			let price = quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice']
			if (price === 0 || price === null){
				price = quotes[ticker.toUpperCase()]['quote']['latestPrice']
			}
			console.log(quotes[ticker.toUpperCase()]['quote'])
			console.log('TICKER AND PRICE', ticker, quotes[ticker.toUpperCase()]['quote']['iexRealtimePrice'])

			let amount = Math.floor(value/price);
			const payload = {
				purchase_date: getCurrDate(),
				purchased_by: userID,
				quantity: amount,
				value: price
			}
			console.log('***********', payload);
			response.status(200).send('success')
			ref.child('teams/'+teamID+'/portfolio/stocks/'+ticker).push(payload);

			// console.log('currval,', curr_val)
			// resolve( curr_val );
			return
		});

    });
});

exports.newChat = functions.https.onRequest((request, response) => {
	const arrayOfUserNames = request.query.userNames;
	let arrayOfUserIDs = []
	const messageText = request.query.messageText;
	const senderID = request.query.senderID;
	let senderName = null
	const userRef = ref.child('users');
	let channelID = null

	// console.log(channelID);
	// console.log(arrayOfUserNames);
	// console.log(messageText);
	// console.log(senderID);
	// console.log(typeof arrayOfUserNames)

	return userRef.once('value').then(snap => {
		Object.keys(snap.val()).forEach(userID => {
			if (arrayOfUserNames.includes(snap.child(userID+'/username').val())) {
				if(senderID===userID){
					senderName = snap.child(userID+'/username').val();
				}
				arrayOfUserIDs.push(userID);
			}
		});
		channelID = arrayOfUserIDs.sort().join('')
		if(snap.child(arrayOfUserIDs[0]).hasChild('messageIDs/'+arrayOfUserIDs.sort().join(''))){
			return []
		}else{
			return arrayOfUserIDs
		}
	}).then(arrayOfUserIDs => {
		messageNode = {
			messageId: guid(),
			messageText: messageText,
			senderID: senderID,
			senderName: senderName,
			sentDate: getDateForMessage()
		}
		if(arrayOfUserIDs.length > 0){
			console.log(arrayOfUserIDs)
			createNewChatChannel(channelID, arrayOfUserIDs, messageNode, arrayOfUserNames.join(', '))
			response.send(true)
		}else{
			sendMessage(channelID, messageNode)
			response.send(false)
		}
		return
	});
});

function sendMessage(channelID, messageNode){
	if(!(messageNode===null)){
		console.log('this should be creating a node under messages')
		ref.child('messages').child(channelID+'/messages').push(messageNode)
	}
}

function createNewChatChannel(channelID, arrayOfUserIDs, messageNode, groupName){
	const chatRef = ref.child('messages');
	const userRef = ref.child('users');

	console.log(messageNode)
	console.log(typeof messageNode)
	let userNode = {}
	arrayOfUserIDs.forEach(userID => {
		userNode[userID] = false
	})
	if(!(messageNode===null)){
		console.log('this should be creating a node under messages')
		chatRef.child(channelID+'/messages').push(messageNode)
		chatRef.child(channelID+'/users').set(userNode)
	}

	return userRef.once('value').then(snap => {
		// Adding the channel ID to each user in the chat
		// unless they are already in it for some reason
		arrayOfUserIDs.forEach(userID => {
			messageIDsNode = snap.child(userID+'/messageIDs')
			if (!messageIDsNode.hasChild(channelID)){
				userRef.child(userID+'/messageIDs/').child(channelID).set(groupName)
				// messageIDsNode.child(channelID).set(true)
			}
		});
		return
	})
}

exports.createTeamMessageChannel = functions.database.ref('teams/{teamID}').onCreate( event => {
	const teamID = event.params.teamID;
	const channelID = teamID;
	const messagesRef = ref.child('messages');
	const teamRef = ref.child(`/teams/${teamID}`)


	return teamRef.once('values').then(snap => {
		arrayOfUserIDs = Object.keys(snap.child('members').val());
		console.log(arrayOfUserIDs)
		let teamName = snap.child('teamName').val()
		if(snap.child('members').val().length === 1 && Object.keys(snap.child('members').val())[0] === teamID){
			// TODO -- confirm this is correct
			response.send(false)
			return
		}else{
			messageNode = {
				messageId: guid(),
				messageText: 'Welcome to the team chat for '+teamName+'! Good luck with your trades!',
				senderID: 'HedgeTeam',
				senderName: 'HedgeTeam',
				sentDate: getDateForMessage()
			}

			createNewChatChannel(channelID, arrayOfUserIDs, messageNode, teamName)
			response.send(true)
			return
		}
	});
});

exports.addTeamMembersToLeagueMessageChannel = functions.database.ref('leagues/{leagueID}/teams/{teamID}').onCreate( event => {
	const leagueID = event.params.leagueID;
	const channelID = leagueID;
	// const messagesRef = ref.child('messages');
	const teamRef = ref.child(`/teams/${teamID}`)
	const leagueRef = ref.child(`/leauges/${leagueID}`);

	let teamMembersPromise = teamRef.child('members').once('values');
	let leagueRefPromise = leagueRef.child('leagueName').once('values');


	return Promise.all([teamMembersPromise, leagueRefPromise]).then(snap => {
		const arrayOfUserIDs = Object.keys(snap[0].val());
		const leagueName = snap[1].val();
		console.log(arrayOfUserIDs)

		createNewChatChannel(channelID, arrayOfUserIDs, null, leagueName)
		response.send(true)
		return
		
	});
});

exports.addNewMemberToTeamMessageChannel = functions.database.ref('teams/{teamID}/members/{userID}').onCreate( event => {
	const teamID = event.params.teamID;
	const channelID = teamID;
	const userID = event.params.userID;

	const leagueRef = ref.child('leagues')
	const teamRef = ref.child(`/teams/${teamID}`)

	

	return leagueRef.once('value').then(snap => {
		let channelIDs = [teamID]
		Object.keys(snap.val()).forEach(leagueID => {
			if(snap.child(leagueID+'/teams').includes(teamID)){
				channelIDs.push(leagueID)
			}
		})
		return channelIDs
	}).then(channelIDs => {
		return teamRef.once('values').then(snap => {
		
			channelIDs.forEach(channelID => {
				createNewChatChannel(channelID, userID, null, snap.child('teamName').val())
			})
			response.send(true)
			return
			
		});
	})
});

exports.addNotificationsAndWelcomeMessageToNewUser = functions.database.ref('users/{userID}').onCreate(event => {
	let messages = []
	console.log(event.params.userID)
	let userID = event.params.userID

	messages.push({
		userID: userID,
		message: 'Welcome to Hedge!',
		type: 'welcome'
	});
	messages.push({
		userID: userID,
		message: 'This is where you will be receiving all of your notifications',
		type: 'welcome'
	});
	messages.push({
		userID: userID,
		message: 'This includes things like portfolio performance, team invites, performance in leauges, and more!',
		type: 'welcome'
	});
	messages.push({
		userID: userID,
		message: 'Good luck, and happy trading!',
		type: 'welcome'
	});

	messages.forEach(message => {
		addNotificationToUser(message)
	})

	//stub user with a single welcome message
	const channelID = userID
	messageNode = {
		messageId: guid(),
		messageText: 'This is going to be the main inbox for all messages and conversations throughout the app. This includes Team chats, League chats, and individual messages.',
		senderID: 'HedgeTeam',
		senderName: 'HedgeTeam',
		sentDate: getDateForMessage()
	}
	createNewChatChannel(channelID, [userID], messageNode, 'Welcome to Hedge')
})









// exports.userDeletedFromTeam = functions.database.ref('teams/{teamID}/members/{memberID}').onCreate( event => {
// 	// const delete_person = event.data.val()
// 	const userID = event.params.memberID;
// 	const teamID = event.params.teamID;
// 	const teamRef = ref.child('teams/'+teamID);
// 	const userRef = ref.child('users/'+userID);

// 	console.log('deleting', userID, teamID);
// 	// console.log()

// 	teamRef.child('member_balances/'+userID).remove();
// 	userRef.child('team_balances/'+teamID).remove();
// 	// console.log('before', snap.child('member_balances').val())

// 	// return teamRef.once('value').then(snap => {
// 	// 	// member_name = snap.child(teamID+'/members/'+event.params.memberID).val()
// 	// 	console.log(userID, snap.child('member_balances').val())
// 	// 	teamRef.child('member_balances/'+userID).remove();
// 	// 	return "success"

// 	// });
// });