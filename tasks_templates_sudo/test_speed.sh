test_speed () {
  url=https://velophil.berlin
  benchrequest -r2 -c15 -s1 "${url}"
  ab -n 100 -c 10 "${url}"
  siege -v -r 2 -c 15 "${url}"

  port=8083
  url=https://velophil.berlin
  oha -n 10000 "${url}"
  reset 
  oha -n 1000000 -c 100 --latency-correction --disable-keepalive "${url}"
  oha -n 1000000 -c 100 --latency-correction --disable-keepalive https://unsaferust.org/
  oha -n 1000000 -c 100 --latency-correction --disable-keepalive https://velophil.berlin
  oha -n 1000000 -c 100 --latency-correction --disable-keepalive https://pixum.de


  port=8083
  url=https://velophil.berlin
  duration=30
  wrk -t 6 -c 1000 -d 3s "${url}"
  reset 
  wrk -t 6 -c 1000 -d ${duration}s "${url}"
  echo "Url tested: ${url}"


} 
