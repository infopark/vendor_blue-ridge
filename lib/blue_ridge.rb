require File.expand_path(File.dirname(__FILE__) + '/work_queue')

module BlueRidge
  JavaScriptSpecDirs = ["examples/javascripts", "spec/javascripts", "test/javascript"]
  
  def self.plugin_prefix
    ENV["BLUE_RIDGE_PREFIX"] || "#{RAILS_ROOT}/vendor/plugins/blue-ridge"
  end
  
  def self.rhino_command
    "java -Dblue.ridge.prefix=\"#{plugin_prefix}\" -jar #{plugin_prefix}/lib/env-js.jar -w -debug"
  end
  
  def self.test_runner_command
    "#{rhino_command} #{plugin_prefix}/lib/test_runner.js"
  end
  
  def self.find_base_spec_dir
    return "examples" if File.exist?("examples")
    return "spec" if File.exist?("spec")
    "test"
  end

  def self.javascript_spec_dir
    base_spec_dir = find_base_spec_dir
    return "test/javascript" if base_spec_dir == "test"
    base_spec_dir + "/javascripts"
  end
  
  def self.find_javascript_spec_dir
    JavaScriptSpecDirs.find {|d| File.exist?(d) }
  end
  
  def self.find_specs_under_current_dir
    Dir.glob("**/*_spec.js")
  end
  
  def self.execute_specs(spec_filenames)
    system("#{test_runner_command} \"#{spec_filenames.join('" "')}\"")
  end

  def self.run_specs_in_dir(spec_dir, spec_name = nil)
    result = nil
    Dir.chdir(spec_dir) { result = run_specs(spec_name) }
    result
  end

  def self.run_specs(spec_name = nil)
    specs = spec_name.nil? ? find_specs_under_current_dir : ["#{spec_name}_spec.js"]
    all_fine = true
    WorkQueue.worker(2) do |task|
      specs.each_slice(8) do |some_specs|
        task.create { all_fine &= execute_specs(some_specs) }
      end
    end
    all_fine
  end
end
