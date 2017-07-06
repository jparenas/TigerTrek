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
        console.log("Status: 400")
        callback({
            authenticated: false,
            data: undefined
          })
      } else if (statusCode != 200) {
        error = new Error('Request Failed.\n' +
                          `Status Code: ${statusCode}`);
      }
      if (error) {
        res.resume();
        console.log(error)
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

app.use(bodyParser.json());
//support parsing of application/x-www-form-urlencoded post data
app.use(bodyParser.urlencoded({ extended: true }));

app.post('/login', function (req, res) {
    token = req.body.token
    authenticate(token, function (user) {
      if (user.authenticated) {
        db.get("SELECT * FROM user WHERE email == \"" + user.data["email"] + "\"", function(err, row) {
                if (row == undefined) {
                  console.log("Registering as " + user.data["email"])
                  res.json({"userRegistered": false});
                } else if (row.email == user.data["email"]){
                  console.log("Logged in as " + user.data["email"])
                  res.json({"userRegistered": true});
                }
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
    console.log(err)
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
      console.log("Registered email " + data["email"])
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
    console.log(err)
  }
  authenticate(data["id"], function (user) {
    if (data["latitude"] && data ["longitude"]) {
      db.serialize(function() {
        db.run("INSERT INTO queue VALUES (?,?,?, '')", user.data["email"], data["latitude"], data["longitude"]) 
      })
      console.log("Emergency reported at lat:" + data["latitude"] + " lon:" + data["longitude"] + " by " + user.data["email"])
    }
  })
})

app.post('/request', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    console.log(err)
  }
  authenticate(data["id"], function (user) {
    db.serialize(function() {
      db.get("SELECT * FROM user WHERE email == \"" + data["email"] + "\"", function(err, row) {
        console.log("Requested data from " + data["email"])
        res.json(row)
      })
    })
  })
})

app.post('/update', function (req, res) {
  try {
    data = JSON.parse(Object.keys(req.body))
  } catch(err) {
    data = req.body
    console.log(err)
  }
  authenticate(data["id"], function (user) {
    db.serialize(function() {
      db.run("DELETE FROM user WHERE email == \"" + data["email"] + "\"")
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
      console.log("Updated information of " + data["email"])
    })
  })
})

app.get('/', function (req, res) {
    res.send("Hallo");
})

app.listen(3000, function () {
    console.log('TigerTrek is now listening on port 3000!')
})

db.serialize(function() {
    db.run("CREATE TABLE IF NOT EXISTS user (email TEXT, name TEXT, height TEXT, weight REAL, hair TEXT, eye TEXT, house TEXT, room INT, allergies TEXT, medications TEXT, contact TEXT)"); 
})