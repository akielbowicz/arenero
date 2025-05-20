$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "uLrZj2OnjkmOkh7YIB5EgXnn.scw3_3", "/", "scw.pjn.gov.ar")))
$session.Cookies.Add((New-Object System.Net.Cookie("cookiesession1", "5675B194XBG9MKIQ5ODRLNGSOYRU711A", "/", "scw.pjn.gov.ar")))
Invoke-WebRequest -UseBasicParsing -Uri "http://scw.pjn.gov.ar/scw/document.seam?id=IfSciqtvU2uAOuy2nsNf6U9Cj0n8tM4PbatnlJP72Fk%3D&tipoDoc=cedula&download=true" `
-WebSession $session `
-UserAgent "Mozilla/5.0 (Windows NT 10.0; rv:124.0) Gecko/20100101 Firefox/124.0" `
-Headers @{
"Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
  "Accept-Language" = "en-US,en;q=0.5"
  "Accept-Encoding" = "gzip, deflate"
  "DNT" = "1"
  "Referer" = "http://scw.pjn.gov.ar/scw/expediente.seam?cid=156740"
  "Upgrade-Insecure-Requests" = "1"
}