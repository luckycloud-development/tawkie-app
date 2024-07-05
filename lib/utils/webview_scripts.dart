const String forceDesktopView = """
  var meta = document.createElement('meta');
  meta.name = 'viewport';
  meta.content = 'width=1024';
  document.getElementsByTagName('head')[0].appendChild(meta);
""";

const String acceptCookies = """
  (function() {
    function clickAcceptButton() {
      var acceptButtons = document.querySelectorAll('button, input[type="button"], input[type="submit"]');
      for (var i = 0; i < acceptButtons.length; i++) {
        var button = acceptButtons[i];
        if (button.innerText.toLowerCase().includes('accept') ||
            button.innerText.toLowerCase().includes('agree') ||
            button.innerText.toLowerCase().includes('autoriser tous les cookies') ||
            button.innerText.toLowerCase().includes('autoriser') ||
            button.innerText.toLowerCase().includes('tous les cookies')) {
          button.click();
        }
      }
    }

    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        clickAcceptButton();
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });

    // Initial check
    clickAcceptButton();
  })();
""";

const String zoomFacebook = """
  (function() {
    document.body.style.zoom = "1.5";
    window.scrollTo(0, 0);
  })();
""";

const String zoomDiscord = """
  (function() {
    document.body.style.zoom = "1.2";
    window.scrollTo(0, 0);
  })();
""";

const String clearCookiesAndStorage = """
  (function() {
    // Clear cookies
    var cookies = document.cookie.split(";");
    for (var i = 0; i < cookies.length; i++) {
      var cookie = cookies[i];
      var eqPos = cookie.indexOf("=");
      var name = eqPos > -1 ? cookie.substr(0, eqPos) : cookie;
      document.cookie = name + "=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/";
    }
    
    // Clear localStorage
    localStorage.clear();
    
    // Clear sessionStorage
    sessionStorage.clear();
  })();
""";

