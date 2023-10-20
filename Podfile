# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ReceiptShoppingApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'RealmSwift', '~>10'
  post_install do |installer|
      installer.aggregate_targets.each do |target|
          if target.name == 'Pods-Target_2' || target.name == 'Pods-Target_1'

              frameworkPath = "Pods/Target Support Files/#{target.name}/#{target.name}-frameworks.sh"

              puts "Found #{frameworkPath}"

              text = File.read(frameworkPath)
              new_contents = text.gsub(/'\$1'/, "\\\"$1\\\"")

              File.open(frameworkPath, "w") {|file| file.puts new_contents}

              puts "Updated #{target.name} framework file with proper EOF characters"
          end
      end
  end

  # Pods for ReceiptShoppingApp

  target 'ReceiptShoppingAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ReceiptShoppingAppUITests' do
    # Pods for testing
  end

end
