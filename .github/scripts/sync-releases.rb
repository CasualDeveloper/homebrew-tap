#!/usr/bin/env ruby

require "digest"
require "json"
require "net/http"
require "uri"

OWNER = "CasualDeveloper"
ROOT = File.expand_path("../..", __dir__)

def get(uri, token:, redirects: 5)
  raise "too many redirects while fetching #{uri}" if redirects.zero?

  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["Authorization"] = "Bearer #{token}" unless token.empty?
  request["User-Agent"] = "CasualDeveloper-homebrew-tap"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    location = response["location"]
    raise "redirect from #{uri} has no location" unless location

    get(URI.join(uri.to_s, location), token: token, redirects: redirects - 1)
  else
    raise "GET #{uri} failed: #{response.code} #{response.message}"
  end
end

def latest_release(repository, token:)
  uri = URI("https://api.github.com/repos/#{OWNER}/#{repository}/releases/latest")
  release = JSON.parse(get(uri, token: token))
  raise "latest #{repository} release is not publishable" if release.fetch("draft") || release.fetch("prerelease")

  match = release.fetch("tag_name").match(/\Av(\d+\.\d+\.\d+)\z/)
  raise "latest #{repository} tag is not vMAJOR.MINOR.PATCH" unless match

  [release, match[1]]
end

def asset(release, name, token:)
  metadata = release.fetch("assets").find { |candidate| candidate.fetch("name") == name }
  raise "release #{release.fetch("tag_name")} is missing #{name}" unless metadata

  url = metadata.fetch("browser_download_url")
  body = get(URI(url), token: "")
  [url, Digest::SHA256.hexdigest(body)]
end

def replace_once(text, pattern, replacement, label)
  matches = text.scan(pattern).length
  raise "expected one #{label}, found #{matches}" unless matches == 1

  text.sub(pattern, replacement)
end

def version_tuple(version)
  version.split(".").map { |component| Integer(component, 10) }
end

def refuse_downgrade(current, latest, product)
  return unless (version_tuple(latest) <=> version_tuple(current)) == -1

  raise "refusing to downgrade #{product} from #{current} to #{latest}"
end

def update_single_asset_formula(repository:, formula:, product:, token:)
  path = File.join(ROOT, "Formula", formula)
  original = File.read(path)
  current = original.match(%r{/releases/download/v(\d+\.\d+\.\d+)/})&.captures&.first
  raise "could not find the current #{product} version" unless current

  release, version = latest_release(repository, token: token)
  refuse_downgrade(current, version, product)
  archive = "#{product}-#{version}.tar.gz"
  url, sha256 = asset(release, archive, token: token)

  updated = replace_once(original, /^  url ".*"$/, "  url \"#{url}\"", "#{product} URL")
  updated = replace_once(updated, /^  sha256 "[0-9a-f]{64}"$/, "  sha256 \"#{sha256}\"", "#{product} SHA-256")
  updated = replace_once(
    updated,
    /(assert_equal "#{Regexp.escape(product)} )\d+\.\d+\.\d+(".*$)/,
    "\\1#{version}\\2",
    "#{product} test version",
  )
  updated = updated.sub(/^  revision \d+\n/, "") if version != current

  File.write(path, updated) if updated != original
  puts "#{product}: #{current} -> #{version}"
end

def update_pinentry_formula(token:)
  product = "pinentry-companion"
  path = File.join(ROOT, "Formula", "pinentry-companion.rb")
  original = File.read(path)
  current = original.match(/^  version "(\d+\.\d+\.\d+)"$/)&.captures&.first
  raise "could not find the current #{product} version" unless current

  release, version = latest_release(product, token: token)
  refuse_downgrade(current, version, product)
  arm_url, arm_sha256 = asset(release, "#{product}-v#{version}-arm64.tar.gz", token: token)
  intel_url, intel_sha256 = asset(release, "#{product}-v#{version}-x86_64.tar.gz", token: token)

  updated = replace_once(original, /^  version "\d+\.\d+\.\d+"$/, "  version \"#{version}\"", "#{product} version")
  updated = replace_once(
    updated,
    /(  on_arm do\n      url ")[^"]+("\n      sha256 ")[0-9a-f]{64}("\n    end)/,
    "\\1#{arm_url}\\2#{arm_sha256}\\3",
    "#{product} arm64 asset",
  )
  updated = replace_once(
    updated,
    /(  on_intel do\n      url ")[^"]+("\n      sha256 ")[0-9a-f]{64}("\n    end)/,
    "\\1#{intel_url}\\2#{intel_sha256}\\3",
    "#{product} x86_64 asset",
  )
  updated = replace_once(
    updated,
    /(assert_match "#{Regexp.escape(product)} )\d+\.\d+\.\d+(".*$)/,
    "\\1#{version}\\2",
    "#{product} test version",
  )

  File.write(path, updated) if updated != original
  puts "#{product}: #{current} -> #{version}"
end

token = ENV.fetch("GITHUB_TOKEN", "")
update_pinentry_formula(token: token)
update_single_asset_formula(
  repository: "pam-companion",
  formula: "pam-companion.rb",
  product: "pam-companion",
  token: token,
)
update_single_asset_formula(
  repository: "AuthCompanion",
  formula: "authcompanion.rb",
  product: "authcompanion",
  token: token,
)
