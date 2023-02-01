var logger = require('morgan');

const createError = require('http-errors');
const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const cookieSession = require("cookie-session");
const WebSocket = require('ws')
const wsServer = new WebSocket.Server({ port: 8000})
const secret = "secretCuisine123";
const app = express();
const port = 3000;

const indexRouter = require('./routes/index');

var CLIENTS=[]; // クライアントのリスト
var id;

wsServer.on('connection', function(ws) {
    id = Math.floor(Math.random() * 999999999);
    console.log('新しいクライアント： ' + id);
    CLIENTS.push(ws); //クライアントを登録

    ws.on('message', function(message) {
        console.log('received: %s', message);
        ws.send("your message : " + message);  // 自分自身にメッセージを返す

        for (var j=0; j < CLIENTS.length; j++) {
          //他の接続しているクライアントにメッセージを一斉送信
            if(ws !== CLIENTS[j]) {CLIENTS[j].send("send from " + id + " : " + message);} 
        }
    });
    

    ws.on('close', function() {
        console.log('ユーザー：' + id + ' がブラウザを閉じました');
        delete CLIENTS[id];
    });
});



//listen
app.listen(port, () => {
    console.log(`Example app listening on port ${port}`);
})

//cookie setup
app.use(
    cookieSession({
        name: "session",
        keys: [secret],
        maxAge: 365 * 24 * 60 * 60 * 1000, // 1 Year
    })
    //cookiesessionのモジュールを使うことで他のスクリプトの中でもreq.sessionで使えるようになる
);

app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    next(createError(404));
});

// error handler
app.use(function (err, req, res, next) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.render('error');
});

