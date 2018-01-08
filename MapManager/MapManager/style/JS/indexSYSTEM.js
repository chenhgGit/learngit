/** Change or delete project
  * and operate is "delete" or "update"
  * and This file code is ~~ UTF-8 ~~
  **/
function getTbodyElement(element, operate) {
  // Get parent element
  var _parrent = element.parentNode.parentNode;
  // Create JSON data object
  var operateJsonData = new Object();   // JSON Object
  var operateJsonOld = [];              // old data
  var operateJsonNew = [];              // new data
  // Get all source value from server
  for ( var _child = 3; _child <= 14; _child+=2) {
    var _childNode = _parrent.childNodes[_child];
    if ( _childNode  &&  _childNode.nodeType == 1 ) {
      if ( _childNode.srcValue != null && _childNode.srcValue != "" ) {
        operateJsonOld.push(_childNode.srcValue);
      }
      if (( _childNode.firstChild ) && ( _childNode.firstChild.tagName == "INPUT" ||
            _childNode.firstChild.tagName == "SELECT" )) {
        operateJsonNew.push(_childNode.firstChild.value);
        if (! _childNode.srcValue )
          operateJsonOld.push(_childNode.firstChild.value);
      }
      else if ( _childNode.innerText != null && _childNode.innerText != "" ) {
        operateJsonNew.push(_childNode.innerText);
        if (! _childNode.srcValue )
          operateJsonOld.push(_childNode.innerText);
      }
      else {
        alert("数据格式错误，包含空值或者无效字符！");
        return false;
      }
    }
  }

  // Get old dato to JSON Object
  operateJsonData["operateJsonOld"] = operateJsonOld.slice(0, 3);

  if ( operate == "update" ) {
    if ( operateJsonOld.toString() == operateJsonNew.toString() ) return false;
    operateJsonData["operateJsonNew"] = operateJsonNew;
    operateJsonData["operate"] = "update";
    if (! confirm("是否继续执行更新操作？")) return false;
  }
  else if ( operate == "delete" ) {
    operateJsonData["operate"] = "delete";
    if (! confirm("是否继续执行删除操作？")) return false;
  }

  // Send Json data to server
  $.post("/operate", JSON.stringify(operateJsonData),
     function(resultData, status) {
       if ( status == "success" && resultData == "success" ) {
         alert("操作成功！");
         window.location.reload(true);
       }
       else {
         alert("操作失败！" + resultData);
       }
     }
  );
  // $.getJSON("/operate", operateJsonData);
}

// Addition Map
function addMap() {
  this.bodyShadowLayer = new shadowLayer(document.body, 1);
  this._bodyShadowLayer = bodyShadowLayer.addShadowLayer();
  // setTimeout(function() { bodyShadowLayer.removeShadowLayer(_bodyShadowLayer) }, 3000)
  // Get Map page
  this._mapPage = document.getElementById("addMap");
  // $(_mapPage).slideDown(1000);
  // get block height
  _height = $(_mapPage).css("height");
  // set height and animate
  $(_mapPage).css("height", "0px")
  .css("display","block")
  .animate({"height":"360px"}, 1000);
}

// Addition Map confirm and submit
function addMapSubmit(element, debug) {
  var _formElement = element.parentNode.parentNode;
  // Addition info list
  var operateList = [];
  // Find data
  for (var _child = 3; _child <= 17; _child += 2) {
    var _childElement = _formElement.childNodes[_child].childNodes[1];
    if (_childElement) {
      if ((_childElement.tagName == "INPUT" ||
          _childElement.tagName == "SELECT") && 
         _childElement.value) {
         operateList.push(_childElement.value);
      }
      else {
        tLog(debug, "数据格式错误！");
        return false;
      }
    }
  }

  if(confirm("是否继续执行添加映射操作？")) {
    // Send Json data to server and data is map connect
    $.post("/operate", JSON.stringify({"operate" : "add", "operateJsonNew" : operateList}),
      function(resultData, status) {
        if ( status == "success" && resultData == "success" ) {
          alert("操作成功！");
          window.location.reload(true);
        }
        else {
          alert("操作失败！" + resultData);
        }
      }
    );
  }
}

/** Create shadow layer
 *   addShadowLayer(element)
 *   removeShadowLayer(Object)
 **/
var shadowLayer = function(element, second) {
  return {
    "addShadowLayer" : function() {
                         if (element.nodeType == 1) {
                           var _createLayer = document.createElement("DIV");
                           _createLayer.style.position = "absolute";
                           _createLayer.style.top = "0px";
                           _createLayer.style.left = "0px";
                           _createLayer.style.zIndex = "100";
                           _createLayer.style.width = "100%";
                           _createLayer.style.height = document.documentElement.scrollHeight + "px";
                           _createLayer.style.opacity = "0";
                           _createLayer.style.background = "black";
                           element.appendChild(_createLayer);
                           if (second && second != 0) {
                             $(_createLayer).animate(
                               {"opacity" : "0.5"},
                               second * 1000
                             );
                           }
                           else {
                             _createLayer.style.opacity = "0.5";
                           }
                           return _createLayer;
                         }
                         return false;
                       },
    "removeShadowLayer" : function(object) {
                            if (element && element.removeChild && object) {
                              if (second && second != 0) {
                                $(object).animate(
                                  {"opacity" : "0"},
                                  second * 1000
                                );
                              }
                              setTimeout(
                                function() { element.removeChild(object); },
                                second * 1000
                              );
                              return true;
                            }
                            return false;
                          }
  }
}

/** Send operate request to server
  * operate is send to server and JSON operate, String
  * logElement is error message to element.innerText, Element
  * update is operate finish and if reload this page, Boolean
  * finishMessage is return "success" and output message, String
  **/
function operateOnly(operate, logElement, update, finishMessage) {
  // Send JSON data to server
  $.post("/operate", JSON.stringify({"operate" : operate}),
      function(resultData, status) {
        if ( status == "success" && resultData == "success" ) {
          alert(finishMessage);
          if (update)
            window.location.reload(true);
        }
        else {
          tLog(logElement, "操作失败！" + resultData);
        }
      }
  );
}

// Server Config refresh
function refreshConfig(debug) {
  // Request update config file on server
  operateOnly("refreshConfig", debug, true, "配置文件更新成功！");
}

// Server IPHelper service and restart
function restartIPHELPER(debug) {
  // Request restart IPHELPER service on server
  operateOnly("restartIPHELPER", debug, false, "重启服务成功！")
}

// Temp message process
function tLog(element, message) {
  element.innerText = message;
  setTimeout(
    function() {
      element.innerText = "";
    },
    3000   // ms
  );
}
