var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  //let name=req.session.username ? req.session.username : "none"
  res.render('index', { title: 'Express' });
});
router.post('/',function(req, res, next) {
  //req.session.username = req.body.username;
  console.log(req.body)
  res.redirect('/');
});
module.exports = router;
