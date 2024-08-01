import React, { useState } from 'react';
import { TextField, Dialog, DialogActions, DialogContent, DialogTitle } from '@material-ui/core';
import Toastr from 'toastr';
import { apiPutRequest } from 'services/apiService';
export default function EditProfile({ open, onClose, profileData, setProfileData }) {
    const [updatedProfileData, setUpdatedProfileData] = useState(profileData);
    const [selectedPicture, setSelectedPicture] = useState(null);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setUpdatedProfileData(prevData => ({
          ...prevData,
          [name]: value
        }));
      };

    const handlePictureChange = (e) => {
        const file = e.target.files[0];
        setSelectedPicture(file);
    };
    const handleSave = async (e) => {
        e.preventDefault();
            const formData = new FormData();
            formData.append('first_name', updatedProfileData.first_name);
            formData.append('last_name', updatedProfileData.last_name);
            if (selectedPicture) {
                formData.append('profile_picture', selectedPicture);
            }
            apiPutRequest('auth/profile/',true,formData)
            .then((response) => {               
                console.log("updaed data from Edit Profile", response.data['User Profile']);
                setProfileData(response.data['User Profile']);
                Toastr.success('Profile Updated Successfully');
                // Close modal
                onClose();
            }).catch((error) => {
                console.error('Error updating profile:', error);
                Toastr.error('Error updating profile:', error);
            });
    };

    return (
        <>
            <Dialog open={open} onClose={onClose}>
                <DialogTitle>Edit Profile</DialogTitle>
                <DialogContent>
                    <TextField
                        label="First Name"
                        name="first_name"
                        value={updatedProfileData.first_name}
                        onChange={handleChange}
                        fullWidth
                    />
                    <TextField
                        label="Last Name"
                        name="last_name"
                        value={updatedProfileData.last_name}
                        onChange={handleChange}
                        fullWidth
                    />
                    <input
                        type="file"
                        accept="image/*"
                        onChange={handlePictureChange}
                        style={{ marginTop: '16px' }}
                    />
                </DialogContent>
                <DialogActions>
                <button className="button-48" onClick={handleSave}>
                        <span>Save</span>
                    </button>
                    <button className="button-48" onClick={onClose}>
                     <span>Cancel</span>  
                    </button>
                </DialogActions>
            </Dialog>
        </>
    )
}
