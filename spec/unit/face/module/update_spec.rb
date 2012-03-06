require 'spec_helper'
require 'puppet/face'
require 'puppet/module_tool'

describe "puppet module update" do
  subject { Puppet::Face[:module, :current] }

  let(:options) do
    {}
  end

  describe "inline documentation" do
    subject { Puppet::Face[:module, :current].get_action :update }

    its(:summary)     { should =~ /update.*module/im }
    its(:description) { should =~ /update.*module/im }
    its(:returns)     { should =~ /hash/i }
    its(:examples)    { should_not be_empty }

    %w{ license copyright summary description returns examples }.each do |doc|
      context "of the" do
        its(doc.to_sym) { should_not =~ /(FIXME|REVISIT|TODO)/ }
      end
    end
  end
end

