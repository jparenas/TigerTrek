var fs = require('fs')
const express = require('express')
const app = express()
const bodyParser = require('body-parser')
const https = require('https')
const sqlite3 = require('sqlite3').verbose(); 

var sqliteFile = "tigerdatabase.sqlite3";

var authenticationCache = []

var db = new sqlite3.Database(sqliteFile); 

function authenticate(token, callback) {
  for (cache in authenticationCache) {
    if (token == authenticationCache[cache]["id"]) {
      log("Using cached data for " + authenticationCache[cache]["email"])
      callback({
        authenticated: true,
        data: authenticationCache[cache]
      })
      return
    }
  }
  https.get('https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=' + token, (res) => {
      const { statusCode } = res;
      const contentType = res.headers['content-type'];

      let error;
      if (statusCode == 400) {
        log("Unauthorized")
        callback({
            authenticated: false,
            data: undefined
          })
        return
      } else if (statusCode != 200) {
        error = new Error('Request Failed.\n' +
                          `Status Code: ${statusCode}`);
      }
      if (error) {
        res.resume();
        log(error)
        return;
      }

      res.setEncoding('utf8');
      let rawData = '';
      res.on('data', (chunk) => { rawData += chunk; });
      res.on('end', () => {
        try {
          const parsedData = JSON.parse(rawData);
          if (parsedData["hd"] == "depauw.edu") {
            parsedData["id"] = token
            authenticationCache.push(parsedData)
            callback({
              authenticated: true,
              data: parsedData
            })
          }
        } catch (e) {
          console.error(e.message);
        }
      });
    }).on('error', (e) => {
      console.error(`Got error: ${e.message}`);
    });
}

function log(message) {
  var now = new Date()
  console.log("[" + now.getDate() + "/" + now.getMonth()+1 + " " + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + "] " + message)
}

app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/login', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
  }
  token = data.token
  authenticate(token, function (user) {
    if (user.authenticated) {
      db.get("SELECT * FROM user WHERE email == ?", user.data["email"], function(err, row) {
        db.get("SELECT * FROM security WHERE email == ?", user.data["email"], function(securityErr, securityRow) {
          if (row == undefined && securityRow == undefined) {
            log("Registering as " + user.data["email"])
            res.json({"userRegistered": false});
          } else if (row.email == user.data["email"] || securityRow.email == user.data["email"]){
            if (securityRow == undefined) {
              security = true
            } else {
              security = true
            }
            log("Logged in as " + user.data["email"] + " isSecurity: " + security)
            res.json({"userRegistered": true, "securityAccess": security});
          }
        })
      })
    } else {
      res.sendStatus(401);
    }
  })
})

app.post('/register', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      names = ["height", "weight", "hair", "eye", "house", "room", "allergies", "medications", "contact"]
      for (name in names) {
        if (!data[names[name]]) {
          if (names[name] == "weight") {
            data[names[name]] = 0
          } else {
            data[names[name]] = ""
          }
        }
      }
      log("Registered email " + data["email"])
      db.serialize(function() {
        db.run("INSERT INTO user VALUES (?,?,?,?,?,?,?,?,?,?,?)", data["email"], data["name"], data["height"], data["weight"], data["hair"], data["eye"], data["house"], data["room"], data["allergies"], data["medications"], data["contact"]) 
      })
      res.json({"userRegistered": true});
      } else {
        res.sendStatus(401);
      }
  })
})

app.post('/emergency', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      if (data["latitude"] && data ["longitude"]) {
        db.get("SELECT * FROM queue WHERE email == ?", data["email"], function(err, row) {
          if (row == undefined) {
            db.run("INSERT INTO queue VALUES (?,?,?,?,?)", data["email"], data["name"], data["latitude"], data["longitude"], Date.now()) 
            log("Emergency reported at lat:" + data["latitude"] + " lon:" + data["longitude"] + " by " + user.data["email"])
          } else {
            log("Attempted to report emmergency by " + user.data["email"] + " but an emergency has already been logged")
          }
        })
      }
    }
  })
})

app.post('/request', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      db.serialize(function() {
        db.get("SELECT * FROM user WHERE email == ?", data["email"], function(err, row) {
          log("Requested data from " + data["email"] + " by " + user.data["email"])
          res.json(row)
        })
      })
    }
  })
})

app.post('/update', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated && user.data["email"] == data["email"]) {
      db.serialize(function() {
        db.run("DELETE FROM user WHERE email == ?", data["email"])
        names = ["height", "weight", "hair", "eye", "house", "room", "allergies", "medications", "contact"]
        for (name in names) {
          if (!data[names[name]]) {
            if (names[name] == "weight") {
              data[names[name]] = 0
            } else {
              data[names[name]] = ""
            }
          }
        }
        db.run("INSERT INTO user VALUES (?,?,?,?,?,?,?,?,?,?,?)", data["email"], data["name"], data["height"], data["weight"], data["hair"], data["eye"], data["house"], data["room"], data["allergies"], data["medications"], data["contact"])
        log("Updated information of " + data["email"])
      })
    }
  })
})

app.post('/cancel', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      db.run("DELETE FROM queue WHERE email = ?", data["email"])
      log("Canceled emergency from " + data["email"])
    }
  })
})

app.post('/get-queue', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      var jsonTable = {"data":[]}
      db.serialize(function() {
        db.each("SELECT * FROM queue", function (err, row) {
          jsonTable["data"].push({"email":row.email,
            "name":row.name,
            "latitude":row.latitude,
            "longitude":row.longitude
          })
        }, function(err, rows) {
          res.json(jsonTable)
          log("Updated queue of " + user.data["email"] + " with a total of " + rows + " rows")
        })
      })
    }
  })
})

app.post('/request-emergency', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    log(err)
  }
  authenticate(data["id"], function (user) {
    if (user.authenticated) {
      db.serialize(function() {
        db.get("SELECT * FROM user WHERE email == ?", data["email"], function(err, row) {
          db.get("SELECT * FROM queue WHERE email == ?", data["email"], function(queueErr, queueRow) {
            log("Requested data from " + data["email"] + " by " + user.data["email"])
            row.latitude = queueRow.latitude
            row.longitude = queueRow.longitude
            console.log(row)
            res.json(row)
          })
        })
      })
    }
  })
})

app.get('/', function (req, res) {
    res.send("Hallo, you shouldn't be here");
})

function cleanQueue() {
  var count = 0
  /*db.each("SELECT * FROM queue", function(err, row) {
    if (Date.now() - row.time >= 3600000) {
      db.run("DELETE FROM queue WHERE email = ?", row.email)
      count++
    }
  })*/
  log("Cleaned " + count + " elements on the queue!")
  count = 0
  date = new Date()
  for (cache in authenticationCache) {
    cacheDate = new Date(authenticationCache[cache]["exp"]*1000)
    if (date.getTime() >= cacheDate.getTime()) {
      authenticationCache.splice(cache)
      count++
    }
  }
  log("Cleaned cache, removing " + count + " entries")
}

/*
https.createServer({
      key: fs.readFileSync('certificates/key.pem'),
      cert: fs.readFileSync('certificates/cert.pem')
    }, app).listen(3443);*/

app.listen(3000)

setInterval(cleanQueue, 300000)