use starknet::{ContractAddress};
use array::ArrayTrait;
use core::option::OptionTrait;

#[derive(Copy, Drop, starknet::Store, Serde)]
enum  UserType {
    Artist,
    Listener,
}

#[derive(Copy, Drop, starknet::Store, Serde)]
struct UserDetails {
    name: felt252,
    country: felt252,
    imgCid1: felt252,
    imgCid2: felt252,
    address: ContractAddress,
    userType: UserType
}

#[derive(Copy, Drop, starknet::Store, Serde)]
struct SoundDetails {
    artist: felt252,
    name: felt252,
    soundCid1: felt252,
    soundCid2: felt252,
}

#[starknet::interface]
trait IBeatDrop<TContractState> {
    fn createProfile(ref self: TContractState, name: felt252, userType: UserType, country: felt252, imgCid1: felt252, imgCid2: felt252);
    fn uploadBeat(ref self: TContractState, beatsName: felt252, soundCid1: felt252, soundCid2: felt252);

    fn getMyprofile(self: @TContractState, address: ContractAddress) -> UserDetails;
    fn searchUserProfile(self: @TContractState, name: felt252) -> UserDetails;

    fn getArtistSongs(self: @TContractState, artistName: felt252) -> Array::<felt252>;
    fn getAllSongs(self: @TContractState) -> Array::<felt252>;
    fn searchSong(self: @TContractState, songName: felt252) -> Array::<felt252>;

    fn createPlaylist(ref self: TContractState, playListName: felt252);
    fn addToplaylist(ref self: TContractState, playlistName:felt252, cid1: felt252, cid2: felt252);
    fn getPlaylists(self: @TContractState, address: ContractAddress) -> Array::<felt252>;
    fn getPlaylistSongs(self: @TContractState, address: ContractAddress, playListName: felt252) -> Array::<felt252>;

    // fn getLatestSongs(self: @TContractState) -> Array::<felt252>;
    // fn getRandomSongs(self: @TContractState) -> Array::<felt252>;

    fn getSongFromCid(self: @TContractState, cid1: felt252, cid2: felt252) -> Array::<felt252>;


}



#[starknet::contract]
mod BeatsDrop {
    use core::starknet::event::EventEmitter;
    use super::{ArrayTrait, ContractAddress, UserType, UserDetails, SoundDetails, IBeatDrop, OptionTrait};
    use starknet::{get_contract_address, get_caller_address};

    #[storage]
    struct Storage {
        addressToArtist: LegacyMap<ContractAddress, felt252>,
        // Site admin storage
        admin: ContractAddress,
        isAdmin: LegacyMap<ContractAddress, bool>,

        // user manager storage
        // takes user address and returns a struct of user details
        users: LegacyMap<ContractAddress, UserDetails>,
        findProfile: LegacyMap<felt252, UserDetails>,
        // confirms user exists
        userNameCheck: LegacyMap<felt252, bool>,
        isUser: LegacyMap<ContractAddress, bool>,
        isArtist: LegacyMap<ContractAddress, bool>,
        // takes user address and keeps track of total uploads by increamenting each by 1
        userTotalUploads: LegacyMap<ContractAddress, u128>,
        // uses address and uplaod number to track each upload
        userUploadCids: LegacyMap<(ContractAddress, u128), SoundDetails>,
        cidsToSong: LegacyMap<(felt252, felt252), SoundDetails>,

        // tracks the number of all uploads on platform by increament each upload by one...
        trackAllSounds: u128,
        // tracks all uploads by there number (from trackAllSounds)
        allSoundDetails: LegacyMap<u128, SoundDetails>,

        // palylist storage
        trackNumberOfPlaylist: LegacyMap<ContractAddress, u16>,
        trackSongInPlaylist: LegacyMap<(ContractAddress, felt252), u16>,
        playlistName: LegacyMap<(ContractAddress, u16), felt252>,
        playlistExist: LegacyMap<(ContractAddress, felt252), bool>,
        playlistContent: LegacyMap<(ContractAddress, felt252, u16), SoundDetails>,
    }
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ProfileCreated: ProfileCreated,
        BeatsUploaded: BeatsUploaded,
    }

    #[derive(Drop, starknet::Event)]
    struct ProfileCreated {
        #[key]
        user: felt252,
        #[key]
        addr: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct BeatsUploaded {
        #[key]
        by: ContractAddress,
        #[key]
        beatsName: felt252,
        #[key]
        cid: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, contractAddr: ContractAddress) {
        self.admin.write(contractAddr);
        self.isAdmin.write(contractAddr, true);
    }

    #[external(v0)]
    impl BeatsDropImpl of IBeatDrop<ContractState>{
        fn createProfile(ref self: ContractState, name: felt252, userType: UserType, country: felt252, imgCid1: felt252, imgCid2: felt252) {
            let user_address = get_caller_address();
            assert(self.isUser.read(user_address) == false, 'User Exists');
            assert(self.userNameCheck.read(name) == false, 'Name Exists');
            let user_profile = UserDetails {name, country, imgCid1, imgCid2, address: user_address, userType};
            self.users.write(user_address, user_profile);
            self.findProfile.write(name, user_profile);
            self.isUser.write(user_address, true);
            self.userNameCheck.write(name, true);
            self.addressToArtist.write(user_address, name);
            self.emit(ProfileCreated{user: name, addr: user_address});
        }

        fn uploadBeat(ref self: ContractState, beatsName: felt252, soundCid1: felt252, soundCid2: felt252) {
            let caller = get_caller_address();
            let artist = self.addressToArtist.read(caller);
            let user_type: UserType = self.users.read(caller).userType;
            let resolve = user_type.processAbstract();
            assert(self.isUser.read(caller) == true, 'SignUp!!');
            assert(resolve == 'Artist', 'Only for Artists');
            self.userTotalUploads.write(caller, self.userTotalUploads.read(caller) + 1);
            self.trackAllSounds.write(self.trackAllSounds.read() + 1);
            let upload_tracker = self.userTotalUploads.read(caller);
            let all_sound_tracker = self.trackAllSounds.read();
            let beats_details = SoundDetails {artist, name: beatsName, soundCid1, soundCid2};
            self.userUploadCids.write((caller, upload_tracker), beats_details);
            self.allSoundDetails.write(all_sound_tracker, beats_details);
            self.cidsToSong.write((soundCid1, soundCid2), beats_details);

        }

        fn getMyprofile(self: @ContractState, address: ContractAddress) -> UserDetails {
            let my_profile = self.users.read(address);
            return my_profile;

        }

        fn searchUserProfile(self: @ContractState, name: felt252) -> UserDetails {
            let search_profile = self.findProfile.read(name);
            return search_profile;
        }

        fn getArtistSongs(self: @ContractState, artistName: felt252) -> Array::<felt252> {
            let artist_address = self.findProfile.read(artistName).address;
            let all_artist_sounds = self.userTotalUploads.read(artist_address);
            let mut i: u128 = 1;
            let mut all_sounds = ArrayTrait::new();

            loop {
                if i <= all_artist_sounds {
                    let artist = self.userUploadCids.read((artist_address, i)).artist;
                    let song = self.userUploadCids.read((artist_address, i)).name;
                    let sound1 = self.userUploadCids.read((artist_address, i)).soundCid1;
                    let sound2 = self.userUploadCids.read((artist_address, i)).soundCid2;
                    all_sounds.append(artist);
                    all_sounds.append(song);
                    all_sounds.append(sound1);
                    all_sounds.append(sound2);
                } else {
                    break;
                }
                i = i + 1;
            };
            return all_sounds;
        }

        fn getAllSongs(self: @ContractState) -> Array::<felt252> {
            let total_songs = self.trackAllSounds.read();
            let mut i: u128 = 1;
            let mut all_sounds = ArrayTrait::new();

            loop {
                if i <= total_songs {
                    let artist = self.allSoundDetails.read(i).artist;
                    let song = self.allSoundDetails.read(i).name;
                    let sound1 = self.allSoundDetails.read(i).soundCid1;
                    let sound2 = self.allSoundDetails.read(i).soundCid2;
                    all_sounds.append(artist);
                    all_sounds.append(song);
                    all_sounds.append(sound1);
                    all_sounds.append(sound2);
                } else {
                    break;
                }
                i = i + 1;
            };
            return all_sounds;
        }

        fn searchSong(self: @ContractState, songName: felt252) -> Array::<felt252> {
            let total_songs = self.trackAllSounds.read();
            let mut i: u128 = 1;
            let mut search_result = ArrayTrait::new();

            loop {
                
                if i <= total_songs {
                    let target = self.allSoundDetails.read(i).name;
                    let target_artist = self.allSoundDetails.read(i).artist;
                    if (target == songName ||  target_artist == songName){
                        let artist = self.allSoundDetails.read(i).artist;
                        let song = self.allSoundDetails.read(i).name;
                        let sound1 = self.allSoundDetails.read(i).soundCid1;
                        let sound2 = self.allSoundDetails.read(i).soundCid2;
                        search_result.append(artist);
                        search_result.append(song);
                        search_result.append(sound1);
                        search_result.append(sound2);
                    } 
                } else {
                    break;
                }
                i = i+1;
            };

            return search_result;
        }

        fn createPlaylist(ref self: ContractState, playListName: felt252) {
            let user = get_caller_address();
            assert(self.isUser.read(user) == true, 'SignUp First');
            assert(self.playlistExist.read((user, playListName)) != true, 'Playlist Exists');
            self.trackNumberOfPlaylist.write(user, self.trackNumberOfPlaylist.read(user) + 1);
            let playlist_tracker = self.trackNumberOfPlaylist.read(user);
            self.playlistName.write((user, playlist_tracker), playListName);
            self.playlistExist.write((user, playListName), true);
        }

        fn addToplaylist(ref self: ContractState, playlistName: felt252, cid1: felt252, cid2: felt252) {
            let user = get_caller_address();
            assert(self.isUser.read(user) == true, 'SignUp First');
            assert(self.playlistExist.read((user, playlistName)) == true, 'Playlist Not Found');
            let song_details = self.cidsToSong.read((cid1, cid2));
            self.trackSongInPlaylist.write((user, playlistName), self.trackSongInPlaylist.read((user, playlistName))+ 1);
            let tracker = self.trackSongInPlaylist.read((user, playlistName));
            self.playlistContent.write((user, playlistName, tracker), song_details);

        }
        fn getPlaylists(self: @ContractState, address: ContractAddress) -> Array::<felt252> {
            assert(self.isUser.read(address) == true, 'SignUp First');
            let playlist_tracker = self.trackNumberOfPlaylist.read(address);
            let mut i: u16 = 1;
            let mut all_playlist = ArrayTrait::new();

            loop {
                if i <= playlist_tracker {
                    let playlist_name = self.playlistName.read((address, i));
                    all_playlist.append(playlist_name);

                } else {
                    break;
                }
                i = i + 1;
            };

            return all_playlist;

        }

        fn getPlaylistSongs(self: @ContractState, address: ContractAddress, playListName: felt252) -> Array::<felt252>{
            assert(self.playlistExist.read((address, playListName)) == true, 'No Playlist');
            let tracker = self.trackSongInPlaylist.read((address, playListName));
            let mut i: u16 = 1;
            let mut all_playlist_songs = ArrayTrait::new();

            loop {
                if i <= tracker{
                    let artist = self.playlistContent.read((address, playListName, i)).artist;
                    let song = self.playlistContent.read((address, playListName, i)).name;
                    let sound1 = self.playlistContent.read((address, playListName, i)).soundCid1;
                    let sound2 = self.playlistContent.read((address, playListName, i)).soundCid2;
                    all_playlist_songs.append(artist);
                    all_playlist_songs.append(song);
                    all_playlist_songs.append(sound1);
                    all_playlist_songs.append(sound2);
                } else{
                    break;
                }
                i = i + 1;
            };
            return all_playlist_songs;
        }

        fn getSongFromCid(self: @ContractState, cid1: felt252, cid2: felt252) -> Array::<felt252> {
            let mut all_playlist_songs = ArrayTrait::new();
            let song_details = self.cidsToSong.read((cid1, cid2));
            let name = song_details.artist;
            let song = song_details.name;

            all_playlist_songs.append(name);
            all_playlist_songs.append(song);

            return all_playlist_songs;

        }

        // fn getLatestSongs(self: @ContractState) -> Array::<felt252>{

        // }
        // fn getRandomSongs(self: @ContractState) -> Array::<felt252>{

        // }

    }














    #[generate_trait]
        impl InternalImpl of InternalTrait {
            fn processAbstract(self: UserType) -> felt252{
                match self{
                    UserType::Artist => {'Artist'},
                    UserType::Listener =>{'Listener'},
                }
            }
        }

}