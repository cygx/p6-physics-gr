use Physics::GR::Categories;
use Physics::GR::LinAlg;
use Physics::GR::SymMath;

class Physics::GR {
    also does Physics::GR::LinAlg;
    also does Physics::GR::SymMath;
}

sub EXPORT { BEGIN Map.new((gr => Physics::GR)) }

multi infix:<(x)>(Tensor $a, Tensor $b) is export { ... }

multi prefix:<->(Symbolic $a) is export { $a.NEG }

multi infix:<*>(Algebraic $a, Algebraic $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Algebraic $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Algebraic $a, Symbolic $b) is export { $a.MUL($b) }
multi infix:<*>(Numeric $a, Algebraic $b) is export { $b.RMUL($a) }
multi infix:<*>(Symbolic $a, Algebraic $b) is export { $b.RMUL($a) }

multi infix:<*>(Symbolic $a, Symbolic $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Symbolic $a, Numeric $b) is export { $a.MUL($b) }
multi infix:<*>(Numeric $a, Symbolic $b) is export { $b.RMUL($a) }
