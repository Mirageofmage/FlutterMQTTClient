function alertMessage(text) {
    alert(text)
}

function checkPerms (){
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
    }
    return Notification.permission
}

function askPerms(){
    Notification.requestPermission();
    return Notification.permission == "granted"
}

function showNotification(title, text){
    if(askPerms()){
        var options = {
            body: text,
        }
        var not = new Notification(title, options);
    }
}