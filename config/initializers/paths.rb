if ENV['SCNR_PRO_DB_DIR']
    FileUtils.mkdir_p ENV['SCNR_PRO_DB_DIR']
end

if ENV['SCNR_PRO_LOG_DIR']
    FileUtils.mkdir_p ENV['SCNR_PRO_LOG_DIR']
end
