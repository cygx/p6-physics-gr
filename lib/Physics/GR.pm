unit package Physics;
use Physics::GR::LinAlg;
use Physics::GR::SymMath;

class GR is export(:MANDATORY, :no-ops) {
    also does LinAlg;
    also does SymMath;
}

multi infix:<*>(Tensor $a, Tensor $b) is export { $a.MUL($b) // $b.RMUL($a) }
multi infix:<*>(Tensor $a, $b) is export { $a.MUL($b) }
multi infix:<*>($a, Tensor $b) is export { $b.RMUL($a) }

multi infix:<(x)>(Tensor $a, Tensor $b) is export { ... }
