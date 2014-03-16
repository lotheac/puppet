require 'spec_helper'
require 'puppet/pops'

describe 'the 4x function api' do
  it 'a simple function can be created without dispatch declaration' do
    f = Puppet::Functions.create_function('min') do
      def min(x,y)
        x <= y ? x : y
      end
    end

    # the produced result is a Class inheriting from Function
    expect(f.class).to be(Class)
    expect(f.superclass).to be(Puppet::Functions::Function)
    # and this class had the given name (not a real Ruby class name)
    expect(f.name).to eql('min')
  end

  it 'a simple function can be called' do
    f = create_min_function_class()
    # TODO: Bogus parameters, not yet used
    func = f.new(:closure_scope, :loader)
    expect(func.is_a?(Puppet::Functions::Function)).to be_true
    expect(func.call({}, 10,20)).to eql(10)
  end

  it 'an error is raised if called with too few arguments' do
    f = create_min_function_class()
    # TODO: Bogus parameters, not yet used
    func = f.new(:closure_scope, :loader)
    expect(func.is_a?(Puppet::Functions::Function)).to be_true
    expect do
      func.call({}, 10)
    end.to raise_error(ArgumentError, Regexp.new(Regexp.escape("function 'min' called with mis-matched arguments
expected:
  min(Optional[Object]{2}) - arg count {2}
actual:
  min(Integer) - arg count {1}")))
  end

  it 'an error is raised if called with too many arguments' do
    f = create_min_function_class()
    # TODO: Bogus parameters, not yet used
    func = f.new(:closure_scope, :loader)
    expect(func.is_a?(Puppet::Functions::Function)).to be_true
    expect do
      func.call({}, 10, 10, 10)
    end.to raise_error(ArgumentError, Regexp.new(Regexp.escape(
"function 'min' called with mis-matched arguments
expected:
  min(Optional[Object]{2}) - arg count {2}
actual:
  min(Integer, Integer, Integer) - arg count {3}")))
  end

  it 'an error is raised if simple function-name and method are not matched' do
    expect do
      f = create_badly_named_method_function_class()
    end.to raise_error(ArgumentError, /Function Creation Error, cannot create a default dispatcher for function 'mix', no method with this name found/)
  end

  it 'the implementation separates dispatchers for different functions' do
    # this tests that meta programming / construction puts class attributes in the correct class
    f1 = create_min_function_class()
    f2 = create_max_function_class()
    d1 = f1.dispatcher
    d2 = f2.dispatcher
    expect(d1).to_not eql(d2)
    expect(d1.dispatchers[0]).to_not eql(d2.dispatchers[0])
    expect(d1.dispatchers[0][1]).to_not eql(d2.dispatchers[0][1].name)
  end

  def create_min_function_class
    f = Puppet::Functions.create_function('min') do
      def min(x,y)
        x <= y ? x : y
      end
    end
  end

  def create_max_function_class
    f = Puppet::Functions.create_function('max') do
      def max(x,y)
        x >= y ? x : y
      end
    end
  end

  def create_badly_named_method_function_class
    f = Puppet::Functions.create_function('mix') do
      def mix_up(x,y)
        x <= y ? x : y
      end
    end
  end
  def alternative
    f = Puppet::Functions.create_function('min') do
      dispatch :min do
        param Numeric, 'a'
        param Numeric, 'b'
      end
      dispatch 'min', integer, integer do
        names 'a', 'b'
      end
      def min(x,y)
        x <= y ? x : y
      end
    end
  end
end