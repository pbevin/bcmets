module Fixpoint
  def fixpoint(x)
    loop do
      next_x = yield x
      return x if x == next_x
      x = next_x
    end
  end
end
