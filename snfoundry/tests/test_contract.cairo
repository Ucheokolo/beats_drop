use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use starknet::{ContractAddress, contract_address_const,ClassHash, get_caller_address};
use starknet::Felt252TryIntoContractAddress;
use snforge_std::{declare, ContractClassTrait, get_class_hash, start_prank};
use beats_drop::beats_drop::{IBeatDropDispatcher, IBeatDropDispatcherTrait, UserType};
use core::zeroable::Zeroable;
use debug::PrintTrait;

#[derive(Copy, Drop, starknet::Store, Serde)]


#[test]
fn test_deployment_works() {
    let beats_drop_address = deploy_beats_drop();
    assert(!beats_drop_address.is_zero(), 'wrong beatsDrop');
    beats_drop_address.print();
}



// #[available_gas(2000000)]
#[test]
fn test_beats_drop() {
    let admin_address = contract_address_const::<'admin_address'>();
    let user = contract_address_const::<'user'>();

    let beats_address = deploy_beats_drop();
    let beatsdrop_dispatcher = IBeatDropDispatcher {contract_address: beats_address};


    start_prank(beats_address, user);
    let user_type: UserType = UserType::Listener;
    beatsdrop_dispatcher.createProfile('Uche', user_type, 'Poland', 'tiyreigeriy377478y4', 'yrfbuyfrwuy47643');
    let res = beatsdrop_dispatcher.getMyprofile(user);
    res.name.print();
    res.country.print();
    res.userType.print();

    start_prank(beats_address, admin_address);
    let user_type: UserType = UserType::Artist;
    beatsdrop_dispatcher.createProfile('Sean', user_type, 'Canada', 'tiyreigeriy377478y4', 'yrfbuyfrwuy47643');
    let res = beatsdrop_dispatcher.getMyprofile(admin_address);
    // res.name.print();
    // res.country.print();
    // res.userType.print();

    start_prank(beats_address, admin_address);
    let res1 = beatsdrop_dispatcher.searchUserProfile('Uche');
    let res2 = beatsdrop_dispatcher.getMyprofile(admin_address);
    // res1.name.print();
    // res1.userType.print();
    // res2.country.print();

    beatsdrop_dispatcher.uploadBeat('baby its You', 'uiytiy78564', 'iueirt57857');
    beatsdrop_dispatcher.uploadBeat('Mexican Girl', 'uiytiyt78564', 'iueirt57857');
    beatsdrop_dispatcher.uploadBeat(' its your life', 'uiytiyt7864', 'iueit57857');
    beatsdrop_dispatcher.uploadBeat('Sean', 'uiytiyt78214', 'iueit57857');

    beatsdrop_dispatcher.getAllSongs();

    start_prank(beats_address, user);
    let res4 = beatsdrop_dispatcher.getArtistSongs('Sean');
    res4.boundary();
    let cid = beatsdrop_dispatcher.getSongFromCid('uiytiyt7864', 'iueit57857');
    'test case'.print();
    cid.boundary();

    'i got here'.print();
    let res5 = beatsdrop_dispatcher.searchSong('Sean');
    'star'.print();
    res5.boundary();

    beatsdrop_dispatcher.createPlaylist('Gospel');
    beatsdrop_dispatcher.createPlaylist('hipHop');
    beatsdrop_dispatcher.createPlaylist('sleep');
    beatsdrop_dispatcher.createPlaylist('jazz');
    beatsdrop_dispatcher.addToplaylist('Gospel', 'uiytiyt7864', 'iueit57857');
    let play_lists = beatsdrop_dispatcher.getPlaylists(user);
    let p_d = beatsdrop_dispatcher.getPlaylistSongs(user,'Gospel');
    'playlist songs'.print();
    p_d.boundary();
    play_lists.boundary();



}


fn deploy_beats_drop() -> ContractAddress {
    let admin_address = contract_address_const::<'admin_address'>();
    let contract = declare('BeatsDrop');
    let name = 'uche';
    let country = 'Canada';
    contract.deploy(@array![admin_address.into()]).unwrap()

}


impl usertypeImpl of PrintTrait<UserType> {
    fn print(self: UserType) {
        match self {
            UserType::Artist => ('Artist').print(),
            UserType::Listener => ('Listener').print(),

        }
    }
}

#[generate_trait]
impl Arry_imp of array_imp_Trait {
    fn boundary(self: Array<felt252>) {
        let mut i: usize = 0;
        loop {
        if i > self.len()-1 {
            break;
        }       
        match self.get(i) {
                Option::Some(x) => {
                  let res =  *x.unbox();
                    res.print();
                },
                Option::None(_) => {
                    let mut data = ArrayTrait::new();
                    data.append('Run finished');
               panic(data)
                },
        }
        i +=1;
        }
    }
}