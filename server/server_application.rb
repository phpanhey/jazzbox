require 'net/http'
require 'uri'
require 'json'
require 'net/ftp'
require 'io/console'
require 'securerandom'
require 'FileUtils'

def outputEmotionData(print_data)
  puts "Jazz Era: " +  print_data["jazz_era"] 
  puts print_data["strongest_emotion"][0] +": " + numberToPercentage(print_data["strongest_emotion"][1])
  puts print_data["medium_emotion"][0] +": " + numberToPercentage(print_data["medium_emotion"][1])
  puts print_data["low_emotion"][0] +": " + numberToPercentage(print_data["low_emotion"][1])
  puts "Timestamp: " + print_data["time_stamp"]
end

def calculateChordName()
  dir = 'sounds'
  file_count = Dir[File.join(dir, '**', '*')].count { |file| File.file?(file) }
  rand_num = rand(1..file_count+1)
  return "ton" + rand_num.to_s + ".wav"
end

def playSound(sound,length)
  `nircmd.exe mediaplay #{length} \"c:\\Users\\Administrator.Strom\\Documents\\jazzbox\\server\\sounds\\#{sound}\"`
end

def printData(print_data)    
  chord_emotion_data = "
  \\backgroundsetup{scale=1,angle=0,opacity=0.9,contents={\\includegraphics[width=\\paperwidth,height=\\paperheight]{#{print_data["file_name"]}}}}
\\begin{flushright}
   \\includegraphics[scale=0.23]{logos/dachmarke}~~~
   \\end{flushright}
\\vspace{3,5cm}
\\begin{minipage}{0.5\\textwidth}
~~~\\includegraphics[scale=0.34]{logos/bremer_moment}
\\vspace{0,2cm} \\par
~~~\\colorbox{white}{\\textbf{EMOTION /}}
\\vspace{0,1cm} \\par
~~~\\colorbox{white}{#{print_data["strongest_emotion"][0].upcase} / #{numberToPercentage(print_data["strongest_emotion"][1])} \\%}
\\vspace{0,1cm} \\par
~~~\\colorbox{white}{#{print_data["medium_emotion"][0].upcase} / #{numberToPercentage(print_data["medium_emotion"][1])} \\%}
\\vspace{0,1cm} \\par
~~~\\colorbox{white}{#{print_data["low_emotion"][0].upcase} / #{numberToPercentage(print_data["low_emotion"][1])} \\%}
\\vspace{0,1cm} \\par
~~~\\colorbox{white}{\\textbf{YOUR JAZZ ERA /} #{print_data["jazz_era"]}}
\\vspace{0,1cm} \\par
~~~\\colorbox{white}{{\\footnotesize TIMESTAMP / #{print_data["time_stamp"]} }}
\\end{minipage}
\\begin{minipage}{0.5\\textwidth}
\\vspace{3,1cm}
    \\begin{flushright}
        \\includegraphics[scale=0.23]{logos/fobi_logo}~~~
    \\end{flushright}
\\end{minipage}
  "  
  File.open("chord_emotion_data.tex", 'w') { |file| file.write(chord_emotion_data) }
  `xelatex latex_template.tex`
  `xelatex latex_template.tex`
  `PDFtoPrinter C:\\Users\\Administrator.Strom\\Documents\\jazzbox\\server\\latex_template.pdf`
  `del *.aux`
  `del *.log`
  `del chord_emotion_data.tex`
end

def calculatePrintData(raw_emotion_data, file_name)
  print_data = Hash.new
  emotion_data_sorted = getEmotionArray(raw_emotion_data)  
  print_data["file_name"] = file_name
  print_data["strongest_emotion"] = emotion_data_sorted[emotion_data_sorted.length-1]
  print_data["medium_emotion"] = emotion_data_sorted[emotion_data_sorted.length-2]
  print_data["low_emotion"] = emotion_data_sorted [emotion_data_sorted.length-3]
  print_data["jazz_era"] = calculateJazzEra(raw_emotion_data)
  print_data["age"] = calculateAverageAge(raw_emotion_data)
  print_data["time_stamp"] = Time.now.strftime("%Y/%m/%d %H:%M")
  return print_data  
end

def calculateJazzEra(raw_emotion_data)
    average_age = calculateAverageAge(raw_emotion_data)
    current_year = Date.today.year
    jazz_era = "Crossover Jazz"
    birthdate = current_year - average_age
    if birthdate>=1920 && birthdate<=1930
      jazz_era = "Swing"
    elsif birthdate>=1931 && birthdate<=1940
      jazz_era = "Be Bop"
    elsif birthdate>=1941 && birthdate<=1950
      jazz_era = "Cool Jazz"
    elsif birthdate>=1951 && birthdate<=1960
      jazz_era = "Free Jazz"
    elsif birthdate>=1961 && birthdate<=1970
      jazz_era = "Soul Jazz"
    elsif birthdate>=1971 && birthdate<=1980
      jazz_era = "Hard Bop"
    elsif birthdate>=1981 && birthdate<=1990
      jazz_era = "Fusion"
    elsif birthdate>=1991 && birthdate<=2000
      jazz_era = "Nu Jazz"
    elsif birthdate>=2001 && birthdate<=2010
      jazz_era = "Crossover Jazz"
    end
    return jazz_era
end

def calculateAverageAge(raw_emotion_data)
  sum = 0.0;
  for emotion_entry in raw_emotion_data do
    sum+=emotion_entry["faceAttributes"]["age"].to_f
  end
  return sum / raw_emotion_data.length 
end

def calculateAverageEmotion(emotion_name, raw_emotion_data)
  sum = 0.0;
  for emotion_entry in raw_emotion_data do
    sum+=emotion_entry["faceAttributes"]["emotion"][emotion_name].to_f
  end
  return sum / raw_emotion_data.length 
end

def getEmotionArray(raw_emotion_data)  
  anger = calculateAverageEmotion("anger",raw_emotion_data)
  contempt = calculateAverageEmotion("contempt",raw_emotion_data)
  fear = calculateAverageEmotion("fear",raw_emotion_data)
  happiness = calculateAverageEmotion("happiness",raw_emotion_data)
  neutral = calculateAverageEmotion("neutral",raw_emotion_data)
  sadness = calculateAverageEmotion("sadness",raw_emotion_data)
  surprise = calculateAverageEmotion("surprise",raw_emotion_data)
  disgust = calculateAverageEmotion("disgust",raw_emotion_data)
  return  { "anger"=>anger, "contempt"=>contempt, "disgust"=>disgust, "fear"=>fear, "happiness"=>happiness, "neutral"=>neutral, "sadness"=>sadness, "surprise"=>surprise}.sort_by { |emotion, emotion_val| emotion_val }
end

def numberToPercentage(float_num)
  return (((float_num * 100 * 1000).floor / 1000.0)).to_s
end

def analyseEmotion(url_link)
  uri = URI('https://westcentralus.api.cognitive.microsoft.com/face/v1.0/detect')
  uri.query = URI.encode_www_form({
    'returnFaceAttributes' => 'emotion,age'
  })
  request = Net::HTTP::Post.new(uri.request_uri)
  request['Content-Type'] = 'application/json'
  request['Ocp-Apim-Subscription-Key'] = '9a4136ae0afa4f78af7ab896d6d818dd'
  request.body = "{\"url\":\"#{url_link}\"}"
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
  end
  return JSON.parse(response.body)
end

def getCredentials
  file = File.open(".ftppass", "rb")
  contents = file.read
  file.close
  contents = JSON.parse(contents)
  return contents
end

def uploadFile(filename)
  ftp_credentials = getCredentials()
  image_obj = File.new(filename)
  Net::FTP.open(ftp_credentials["ftp_host"], ftp_credentials["username"], ftp_credentials["password"]) do |ftp|
    ftp.putbinaryfile(image_obj, "/face_recognition/#{File.basename(image_obj)}")
  end
  image_obj.close
end

def makeScreenshot(filename)
  `nircmd.exe savescreenshot #{filename}`
end

def getRandomFileName
  return SecureRandom.base64(8).gsub("/","_").gsub(/=+$/,"") + ".jpg"
end

def deleteScreenshots
  Dir.glob(File.join(File.dirname(__FILE__), './*.jpg')).each { |file| File.delete(file)}
end

def saveInFile(file_name, data_to_save)
  open(file_name, 'a') do |f|
    f.puts data_to_save.to_json
  end
end

while true
  #puts("\n\n")
  system "cls"
  puts "press button"
  input = STDIN.getch  
  puts "Please wait. Analysing..."
  random_filename = getRandomFileName()
  makeScreenshot random_filename
  playSound("camera_sound.wav",3000)
  uploadFile random_filename
  raw_emotion_data = analyseEmotion ("http://facerecognition.philipp-panhey.de/" + random_filename)
  if raw_emotion_data.is_a?(Array) && raw_emotion_data.length != 0
     print_data = calculatePrintData(raw_emotion_data, random_filename)    
     outputEmotionData(print_data)
     printData(print_data)
     playSound(calculateChordName(),5000)
     saveInFile("printdata.txt", print_data)
     puts "Plotting image data. Please wait..."
     sleep(10)
  else
    puts "no emotion found."
    sleep(3)
  end
  deleteScreenshots()
  
end