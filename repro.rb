# frozen_string_literal: true

require 'selenium-webdriver'

driver = ENV['DRIVER'] || 'chrome'
page_load_strategy = ENV['PAGE_LOAD_STRATEGY'] || 'none'
sleep_time = (ENV['SLEEP_TIME'] || 1).to_f
max_tries = (ENV['MAX_TRIES'] || 5).to_i
max_iterationes = (ENV['MAX_ITERATIONS'] || 30).to_i

def has_body_content(driver)
    results = driver.find_elements xpath: '/html/body/*'
    results.size > 0
end

def has_no_body_content(driver)
    results = driver.find_elements xpath: '/html/body/*'
    results.size == 0
end

Selenium::WebDriver.logger.level = :info

case driver
when 'chrome'
    driver = Selenium::WebDriver.for :chrome,
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
            pageLoadStrategy: page_load_strategy
        )
when 'remote'
    driver = Selenium::WebDriver.for :remote,
        url: 'http://127.0.0.1:9515',
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
            pageLoadStrategy: page_load_strategy
        )
when 'remote_container'
    begin
        socket = TCPSocket.open 'selenium', 4444
        socket.close
    rescue StandardError => e
        puts 'Waiting for selenium to start'
        sleep 0.1
        retry
    end

    driver = Selenium::WebDriver.for :remote,
        url: 'http://selenium:4444/wd/hub',
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
            pageLoadStrategy: page_load_strategy
        )
when 'firefox'
    driver = Selenium::WebDriver.for :firefox,
        desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(
            pageLoadStrategy: page_load_strategy
        )
end

loop_iteration = 1

begin
    until loop_iteration > max_iterationes do
        driver.navigate.to 'about:blank'

        try_count = 1
        until has_no_body_content driver
            try_count += 1
            throw 'Could not navigate to about:blank #1' if try_count > max_tries
            sleep sleep_time
        end

        driver.navigate.to 'https://example.com'

        try_count = 1
        until has_body_content driver
            try_count += 1
            throw 'Could not navigate to example.com' if try_count > max_tries
            sleep sleep_time
        end

        driver.navigate.to 'about:blank'

        try_count = 1
        until has_no_body_content driver
            try_count += 1
            throw 'Could not navigate to about:blank #2' if try_count > max_tries
            sleep sleep_time
        end

        driver.navigate.to 'data:,'

        try_count = 1
        until has_body_content driver
            try_count += 1
            throw 'Could not navigate to data:,' if try_count > max_tries
            sleep sleep_time
        end

        loop_iteration += 1
    end

    puts 'No repro'
    driver.quit
rescue StandardError => e
    puts "Repro successful: Failed after loop iteration ##{loop_iteration}: #{e.to_s}"
    driver.quit
    throw e
end

# vim: ts=4 sw=4 sts=4 sr et
