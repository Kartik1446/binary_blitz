import "src/CheeseLending.sol";
import "src/Cheese.sol";


contract Cow{

    CheeseLending cheeseLending;

    constructor(CheeseLending lending){
        cheeseLending = lending;
    }


    bool _init = false;

    function init(Cheese gruyere , Cheese emmental ) public{
        require(!_init);
        _init = true;

        gruyere.approve(address(cheeseLending), 2**256-1);
        emmental.approve(address(cheeseLending), 2**256-1);

        cheeseLending.supply(address(emmental), emmental.balanceOf(address(this)));
        cheeseLending.supply(address(gruyere),  gruyere.balanceOf(address(this)));
    }    
}