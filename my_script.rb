platform :ios, '16.0'

use_frameworks!
use_modular_headers!

target 'QuestMe' do
  # Google Maps SDK
  pod 'GoogleMaps'
  pod 'Google-Maps-iOS-Utils'

  # SQLite.swift
  pod 'SQLite.swift', '~> 0.15.3'

  target 'QuestMeTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QuestMeUITests' do
    # Pods for testing
  end
end

