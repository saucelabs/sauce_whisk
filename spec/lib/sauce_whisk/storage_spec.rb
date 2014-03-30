require 'spec_helper'

describe SauceWhisk::Storage, :vcr => { :cassette_name => 'storage' } do
  before do
    @file_name = 'temp.apk'
    @temp_file = Tempfile.new @file_name

    begin
      @temp_file.write 'data'
    ensure
      @temp_file.close
    end
  end

  after do
    @temp_file.unlink
  end

  it 'uploads a file with username and key' do
    storage = SauceWhisk::Storage.new username: ENV['SAUCE_USERNAME'], key: ENV['SAUCE_ACCESS_KEY']
    storage.upload @temp_file
  end

  it 'uploads a file with implicit auth' do
    storage = SauceWhisk::Storage.new
    storage.upload @temp_file
  end

  it 'lists all uploaded files' do
    storage = SauceWhisk::Storage.new
    files   = storage.files
    expect(files.length).to be > 1

    upload_successful = files.any? do |file|
      file['name'].include?(@file_name)
    end
    expect(upload_successful).to be true
  end
end