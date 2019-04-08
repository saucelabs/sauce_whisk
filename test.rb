require "sauce_whisk"

SauceWhisk.data_center = :eu
SauceWhisk.logger.level = Logger::DEBUG

SauceWhisk::Accounts.concurrency_for "dylanatsauce"
