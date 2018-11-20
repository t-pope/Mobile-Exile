var timeoutSeconds = 30;

var username = "%@";
var password = "%@";

var checkLogin = setInterval(checkLoginFields, 1000);
setTimeout(function() {
           clearInterval(checkLogin);
           }, timeoutSeconds * 1000);

function checkLoginFields() {
    var usernameInput = document.getElementById('login_email');\
    var passwordInput = document.getElementById('login_password');\
    var signInButton = document.getElementById("login_submit");\
    if (signInButton == null) {
        return;
    }
    usernameInput.value = username;
    passwordInput.value = password;
    signInButton.click();
    clearInterval(checkLogin);
}
