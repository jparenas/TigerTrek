var fs = require('fs')
const express = require('express')
const app = express()
const bodyParser = require('body-parser')
const https = require('https')
const sqlite3 = require('sqlite3').verbose(); 

var sqliteFile = "tigerdatabase.sqlite3";

var db = new sqlite3.Database(sqliteFile); 

function authenticate(token, callback) {
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
          callback({
            authenticated: true,
            data: parsedData
          })
        } catch (e) {
          console.error(e.message);
        }
      });
    }).on('error', (e) => {
      console.error(`Got error: ${e.message}`);
    });
}

function log(message) {
  console.log("[" + Date.getDate() + "/" + Date.getMonth + " " + Date.getHours() + ":" + Date.getMinutes() + ":" + Date.getSeconds() + "] " + message)
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
              security = false
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
            db.run("INSERT INTO queue VALUES (?,?,?,?,?)", user.data["email"], user.data["name"], data["latitude"], data["longitude"], Date.now()) 
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

app.get('/', function (req, res) {
    res.send("Hallo, you shouldn't be here");
})

function cleanQueue() {
  log("Cleaning Queue!")
  /*db.each("SELECT * FROM queue", function(err, row) {
    if (Date.now() - row.time >= 3600000) {
      db.run("DELETE FROM queue WHERE email = ?", row.email)
      log("Deleted emergency of " + row.email)
    }
  })*/
}

/*
https.createServer({
      key: fs.readFileSync('certificates/key.pem'),
      cert: fs.readFileSync('certificates/cert.pem')
    }, app).listen(3443);*/

app.listen(3000)

setInterval(cleanQueue, 60000)