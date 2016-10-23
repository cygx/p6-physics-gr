use Physics::GR::LinAlg;
use Physics::GR::SymMath;

sub EXPORT(*@list) {
    Map.new(
        Physics::GR::LinAlg::EXPORT::DEFAULT::.pairs,
        Physics::GR::SymMath::EXPORT::DEFAULT::.pairs
    );
}
