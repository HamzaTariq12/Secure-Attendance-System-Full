import React, { useEffect, useState } from 'react'
import TextField from '@material-ui/core/TextField';
import Avatar from '@material-ui/core/Avatar';
import { Box, Card, FormControl, Typography } from '@mui/material';
import { apiGetRequest } from 'services/apiService';
import EditProfile from './modal/editProfile';
import { HashLoader } from 'react-spinners';
export default function Profile() {
  const [loading, setLoading] = useState(true);
  const [profileData, setProfileData] = useState({
    id: '',
    first_name: '',
    last_name: '',
    email: '',
    profile_picture: "",
  });
  useEffect(() => {
    apiGetRequest('auth/profile/')
      .then(response => {
        const userProfile = response.data['User Profile'];
        if (userProfile) {
          setProfileData(userProfile);
          setLoading(false);
        } else {
          console.error('User Profile data not found in the response:', response);
        }
      })
      .catch(error => {
        console.error('Error fetching profile data:', error.message);
      });
  }, []);
  // Edit Profile Modal Opening
  const [iseditProfile, setEditProfile] = useState(false)
  const handleEditProfileClose = () => {
    setEditProfile(false)
  };
  const handleEditprofile = () => {
    setEditProfile(true)

  };
  return (
    <>
      <Card style={{ marginLeft: '140px', width: '70%', height: '400px' }}>
        <FormControl style={{ width: '500px', height: '600px', paddingLeft: '100px', marginTop: '60px' }}>
        {loading ? (
                    <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                       <HashLoader color="#1976d2" />
                    </Box>
                ) : (
          <Box>
            <div style={{ display: 'flex', flexDirection: 'row', justifyContent: 'space-between' }}>
              <div>
                <Avatar
                  alt="Profile Picture"
                  src={profileData.profile_picture}
                  style={{ width: '140px', height: '140px' }}
                />
                <Typography>
                  Profile Picture
                </Typography>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  <TextField disabled
                  id="outlined-disabled" label="First Name" variant="standard" value={profileData.first_name || ''}  />
                <TextField disabled
                  id="outlined-disabled" label="Last Name" variant="standard" value={profileData.last_name || ''}  />
                <TextField disabled
                  id="outlined-disabled" label="Email" variant="standard" value={profileData.email} />
                <button
                  style={{
                    width: '240px',
                    height: '50px',
                    border: 'none',
                    backgroundColor: '#1976d2',
                    color: 'white',
                    fontSize: '15px',
                    borderRadius: '12px',
                  }}
                  onClick={handleEditprofile}
                >
                  Edit Profile
                </button>
              </div>
            </div>
          </Box>
             )}
        </FormControl>
      </Card>
      {iseditProfile && (
        <EditProfile open={iseditProfile} onClose={handleEditProfileClose} profileData={profileData} setProfileData={setProfileData}  />
      )}
    </>
  )
}
