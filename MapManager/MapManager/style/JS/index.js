/** Login or Select for all users
  * and This file code is ~~ UTF-8 ~~
  **/
$(document).ready(
  function() {
    resizePage();
    window.onresize = function() { window.location.reload(false); }
  }
);

// Set page size
function resizePage() {
  // Get page visible height
  var clientHeight = document.body.scrollHeight;
  // Get page full height
  var pageFullHeight = document.documentElement.scrollHeight;
  var frameDiv = $(".frameDiv");
  if (parseInt(clientHeight) > parseInt(pageFullHeight)) {
    frameDiv.css("_height", (clientHeight - 15) + "px").css("min-height", (clientHeight - 15) + "px");
  }
  else {
    frameDiv.css("height", pageFullHeight);
  }
}

// Login page process
function loginSubmit(element, log) {
  // Create object and save json data
  var loginJSON = new Object();
  // Get username
  loginJSON["userAuth"] = element.authUser.value;
  // Get password
  loginJSON["passAuth"] = element.authPass.value;
  if (loginJSON["userAuth"] == "" ||
      loginJSON["passAuth"] == "") {
    tLogLogin(log, "用户名或者密码不能为空！");
    return false;
  }

  // Submit user info
  $.post("/login", JSON.stringify(loginJSON),
      function(resultData, status) {
        if ( status == "success" && resultData == "success" ) {
          window.location.reload(true);
        }
        else {
          tLogLogin(log, "登录失败！ " + resultData);
        }
      }
  );
}

// Temp message process for jQuery
function tLogLogin(element, message) {
  element.text(message);
  setTimeout(
    function() {
      element.text("");
    },
    3000   // ms
  );
}
