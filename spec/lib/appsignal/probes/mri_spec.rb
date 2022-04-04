describe Appsignal::Probes::MriProbe do
  let(:probe) { described_class.new }

  describe ".dependencies_present?" do
    if DependencyHelper.running_jruby? || DependencyHelper.running_ruby_2_0?
      it "should not be present" do
        expect(described_class.dependencies_present?).to be_falsy
      end
    else
      it "should be present" do
        expect(described_class.dependencies_present?).to be_truthy
      end
    end
  end

  unless DependencyHelper.running_jruby? || DependencyHelper.running_ruby_2_0?
    describe "#call" do
      it "should track vm metrics" do
        expect_distribution_value(:class_serial)
        expect_distribution_value(:global_constant_state)

        probe.call
      end
    end unless DependencyHelper.ruby_version >= Gem::Version.new("3.2.0")
    # TODO: fix the above test/implementation for Ruby 3.2 before merging

    def expect_distribution_value(metric)
      expect(Appsignal).to receive(:add_distribution_value)
        .with("ruby_vm", kind_of(Numeric), :metric => metric)
        .and_call_original
        .once
    end
  end
end
