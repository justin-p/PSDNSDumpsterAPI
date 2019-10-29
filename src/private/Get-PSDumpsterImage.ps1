$image='https://dnsdumpster.com/static/map/justin-p.me.png'
Invoke-WebRequest $image -OutVariable imagevariable
$base64String = [convert]::ToBase64String($imagevariable.content)