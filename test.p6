use lib 'lib';

{
    use Physics::GR;
    say unit-matrix(3) * vector(1, 2, 3);
}

{   # TODO
    use Physics::GR <*>;
    say GR::unit-matrix(3) * GR::vector(1, 2, 3);
}
