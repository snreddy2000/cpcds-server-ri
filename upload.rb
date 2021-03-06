require 'httparty'

TEST_DATA_DIR = "data"
BEARER_TOKEN = ""
FHIR_SERVER = 'http://localhost:8080/cpcds-server/fhir/'
DEBUG = false # Set to true to only upload first bundle
$count = 0


def upload_test_patient_data(server)
    file_path = File.join(__dir__, TEST_DATA_DIR, '*.json')
    filenames = Dir.glob(file_path)
    filenames.each do |filename|
        bundle = JSON.parse(File.read(filename), symbolize_names: true)
        upload_bundle(bundle, server)
        break if DEBUG
    end
end

def upload_bundle(bundle, server)
    puts "Uploading bundle #{bundle[:entry][0][:resource][:id]}..."
    begin
        response = HTTParty.post(server, 
            body: bundle.to_json, 
            headers: { 'Content-Type': 'application/json', 'Authorization': BEARER_TOKEN }
        )
        response.code >= 200 && response.code < 300 ? (puts "  ...uploaded bundle #{$count}"; $count += 1) : (puts "  ...FAILED: code #{response.code}")
        rescue StandardError
    end
end

if ARGV.length == 0
    server = FHIR_SERVER
else
    server = ARGV[0]
end

puts "POSTING patient bundles to #{server}"
upload_test_patient_data(server)
puts "Uploaded #{$count} patient bundles to #{server}"