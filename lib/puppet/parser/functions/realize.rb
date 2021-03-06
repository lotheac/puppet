# This is just syntactic sugar for a collection, although it will generally
# be a good bit faster.

Puppet::Parser::Functions::newfunction(:realize, :arity => -2, :doc => "Make a virtual object real.  This is useful
    when you want to know the name of the virtual object and don't want to
    bother with a full collection.  It is slightly faster than a collection,
    and, of course, is a bit shorter.  You must pass the object using a
    reference; e.g.: `realize User[luke]`." ) do |vals|

    vals = [vals] unless vals.is_a?(Array)
    if Puppet[:parser] == 'future'
      coll = Puppet::Pops::Evaluator::Collectors::FixedSetCollector.new(self, vals.flatten)
    else
      coll = Puppet::Parser::Collector.new(self, :nomatter, nil, nil, :virtual)
      coll.resources = vals.flatten
    end

    compiler.add_collection(coll)
end
