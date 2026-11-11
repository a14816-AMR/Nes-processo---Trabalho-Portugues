param([int]$Port = 5500)
$root = $PSScriptRoot
$mime = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css'; '.js'='text/javascript'; '.svg'='image/svg+xml'; '.png'='image/png'; '.jpg'='image/jpeg'; '.webp'='image/webp' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Servidor em http://localhost:$Port/"
while ($l.IsListening) {
  $c = $l.GetContext()
  $path = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath).TrimStart('/')
  if ($path -eq '') { $path = 'index.html' }
  $file = Join-Path $root $path
  if ((Test-Path $file -PathType Leaf) -and ($file.StartsWith($root))) {
    $bytes = [IO.File]::ReadAllBytes($file)
    $ext = [IO.Path]::GetExtension($file).ToLower()
    $c.Response.ContentType = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
    $c.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $c.Response.StatusCode = 404
  }
  $c.Response.Close()
}
