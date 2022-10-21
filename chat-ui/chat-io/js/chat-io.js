var sentinel_id = document.getElementById("app-interact").getAttribute('data-sentinelid');
var server = document.getElementById("app-interact").getAttribute('data-server');
var walker = document.getElementById("app-interact").getAttribute('data-walkername');
var token = document.getElementById("app-interact").getAttribute('data-token');
var last_jid = null;

// // Replace the script tag with the app
document.getElementById('app-interact').parentNode.innerHTML = `
<div id="chatio__${sentinel_id}">
<header class="app-header">
  <div class="centered">
  <div id="chatio__input">
    <div class="__header">

    </div>
    <div class="__body">
      <div id="chatio__dialog">
          <ol class="chat-messages-list"></ol>
      </div>
    </div>
    <div class="__footer">
      <div class="chat-loader-container">
        <div class="chat-loader-bar"></div>
        <div class="chat-info-container"></div>
      </div>
      
      <form id="chatio__inputForm" autocomplete="off">
        <input id="chatio__inputField" type="text" placeholder="ask me something..." class="dark-bg"/>
        <button type="submit" id="chatio__submit">
          <svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 488.721 488.721" style="fill: white; enable-background:new 0 0 488.721 488.721;" xml:space="preserve"> <g> <g> <path d="M483.589,222.024c-5.022-10.369-13.394-18.741-23.762-23.762L73.522,11.331C48.074-0.998,17.451,9.638,5.122,35.086 C-1.159,48.052-1.687,63.065,3.669,76.44l67.174,167.902L3.669,412.261c-10.463,26.341,2.409,56.177,28.75,66.639 c5.956,2.366,12.303,3.595,18.712,3.624c7.754,0,15.408-1.75,22.391-5.12l386.304-186.982 C485.276,278.096,495.915,247.473,483.589,222.024z M58.657,446.633c-8.484,4.107-18.691,0.559-22.798-7.925 c-2.093-4.322-2.267-9.326-0.481-13.784l65.399-163.516h340.668L58.657,446.633z M100.778,227.275L35.379,63.759 c-2.722-6.518-1.032-14.045,4.215-18.773c5.079-4.949,12.748-6.11,19.063-2.884l382.788,185.173H100.778z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>&nbsp;
        </button>
      </form>
    </div>
  </div>
  </div>
</header>
</div>`;

var inputForm = document.getElementById('chatio__inputForm');
var inputField = document.getElementById('chatio__inputField');
var messagesList = document.querySelector('.chat-messages-list');
var messageDialog = document.getElementById("chatio__dialog");
var chatLoaderContainer = document.querySelector('.chat-loader-container');
var chatInfoContainer = document.querySelector('.chat-info-container');
var ischatThinking = false;

function walker_run(name, question="", nd = null) {

  query = `
  {
    "name": "${name}",
    "ctx": {"question": "${question}"},
    "snt": "${sentinel_id}",
    "detailed":"false"
  }
  `;

  if(nd) { //if we have a node param
    query = `
    {
      "name": "${name}",
      "nd" : "${nd}",
      "ctx": {"question": "${question}"},
      "snt": "${sentinel_id}",
      "detailed":"false"
    }
    `;
  }

  return fetch(`${server}/js/walker_run`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `token ${token}`
    },
    body: query,
  }).then(function (result) {
    return result.json();
  });
}

//attribution: https://stackoverflow.com/a/11833777
function addCss(fileName) {

  var head = document.head;
  var link = document.createElement("link");
  link.type = "text/css";
  link.rel = "stylesheet";
  link.href = fileName;

  head.appendChild(link);
}

function addJs(fileName) {

  var body = document.body;
  var link = document.createElement("script");
  link.type = "text/javascript";
  link.src = fileName;

  body.appendChild(link);
}

//attribution: https://medium.com/beginners-guide-to-mobile-web-development/one-off-event-listeners-in-javascript-92e19c4c0336
function createOneTimeListener(element, event, listener) {
	// first we call addEventListener on element with event name
	// then inside the callback function, we first un-register the listener
	// and return the original listener passed to attach it with the event
	element.addEventListener(event, function() {
		element.removeEventListener(event, arguments.callee);
		return listener();
	});
}

function addMessage(message, self){

  var messageContainer = document.createElement('li');
  messageContainer.classList.add('chat-message');
  if(self) messageContainer.classList.add('chat-message-self');
  else messageContainer.classList.add('chat-message-friend');
  messagesList.appendChild(messageContainer);

  var messageBubble = document.createElement('div');
  messageBubble.classList.add('chat-message-bubble');
  messageContainer.appendChild(messageBubble);
  messageBubble.innerHTML = message;

  var oldScroll = messageDialog.scrollTop;
  messageDialog.scrollTop = 9999999;
  var newScroll = messageDialog.scrollTop;
  var scrollDiff = newScroll - oldScroll;
  TweenMax.fromTo(
    messageDialog,0.4,{
      y:scrollDiff
    },{
      y:0,
      ease:Quint.easeOut
    }
  );

  return {
    container: messageContainer,
    bubble: messageBubble
  };
}

function chatIsThinking(){
  if(ischatThinking) return;
  ischatThinking = true;

  var dots = document.createElement("div");
  dots.classList.add('chat-effect-dots');
  dots.style.top = -130;
  dots.style.left = 10;
  chatLoaderContainer.appendChild(dots);

  for (var i = 0; i < 3; i++) {
    var dot = document.createElement("div");
    dot.classList.add('chat-effect-dot');
    dot.style.left = i*20;
    dots.appendChild(dot);

    TweenMax.to(dot,0.3,{
      delay:-i*0.1,
      x:30,
      yoyo:true,
      repeat:-1,
      ease:Quad.easeInOut
    })
  };

  var info=document.createElement("div");
  info.classList.add("chat-info-typing");
  info.innerHTML = "replying...";
  info.style.transform = "translate3d(0,30px,0)";
  chatInfoContainer.appendChild(info);

  TweenMax.to(info, 0.3,{
    x:0,
    force3D:true
  });

}

function chatStoppedThinking() {

  if(!ischatThinking) return

  ischatThinking=false;

  var dots = document.querySelector(".chat-effect-dots");
  TweenMax.to(dots,0.3,{
    x:40,
    force3D:true,
    ease:Quad.easeIn,
  });

  var info = document.querySelector(".chat-info-typing");
  TweenMax.to(info,0.3,{
    x:30,
    force3D:true,
    ease:Quad.easeIn,
    onComplete:function(){
      dots.remove();
      info.remove();

    }
  });
}

function interact(event) {

  if(event) event.preventDefault();

  let question = inputField.value;
  if (question.trim()) {
    inputField.value = "";
    addMessage(question,true);

    chatIsThinking();

    walker_run(walker, question, last_jid).then((result) => {

      if(result.report[0]) {

        //if we have an intent, we save the position on graph, otherwise we reset to root
        if(result.report[0].intent) { 
          last_jid = result.report[0].node.jid;
        } else last_jid = null;

        //show the response message in the chat
        if(Array.isArray(result.report[0])) {
          for(let mes in result.report[0]){
            addMessage(result.report[0][mes]) ;
          }
        }
        else{
          addMessage(result.report[0]); 
        }
         
      
      } 
      else last_jid = null;

      chatStoppedThinking(); 

    }).catch(function (error) {
        console.log(error);
    });
  }
}

//add stylesheet
addCss(`chat-io/css/chat-io.css`);
//add Js
addJs(`chat-io/js/TweenMax.min.js`);
//add event listener to the input field
inputForm.addEventListener("submit", interact);

addMessage("Welcome Traveler, How can i Help?  Want to book a flight or Cancel a flight or even ask a question , Don't be shy just ask !");

