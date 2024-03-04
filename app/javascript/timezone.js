function setTimeZoneCookie () {
  const tz = Intl.DateTimeFormat().resolvedOptions().timeZone

  setCookie('timezone', tz)

  function setCookie (key, value) {
    const expires = new Date()
    const currentTime = expires.getTime()
    const duration = (24 * 60 * 60 * 1000) // 24 hours
    expires.setTime(currentTime + duration)

    document.cookie = key + '=' + value + ';Expires=' + expires.toUTCString() + ';SameSite=Strict' + ';Path=/'
  }
}

setTimeZoneCookie()
