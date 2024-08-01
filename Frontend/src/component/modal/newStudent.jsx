import React, { useState, useEffect } from 'react'
import { Box, Container, Typography, IconButton, TextField, Button } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import Modal from '@mui/material/Modal';
import toastr from 'toastr';
import { apiGetRequest } from 'services/apiService';
const style = {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: 600,
    height: 200,
    bgcolor: 'background.paper',
    border: '2px solid #000',
    boxShadow: 24,
    p: 1,
};

export default function NewStudent({ open, onClose,addedStudent }) {
    const [registrationNumber, setRegistrationNumber] = useState('');
    // const [data, setdata] = useState([]);
    const [error, setError] = useState(null);
    useEffect(() => {
        senddata()
      },[]);

    const handleRegistrationNumberChange = (event) => {
        setRegistrationNumber(event.target.value);
        setError(null); 
      };

      const senddata = () => {
          if (registrationNumber.trim() !== '') {
            const apiUrl = `teacher-courses/students/?course_id=${1}&roll_no=${registrationNumber}`
            apiGetRequest(apiUrl)
              .then(responseData => {
                addedStudent(responseData)
                onClose();
                toastr.success('New Student added successfully');
                setError(null); 
              })
              .catch(error => {
                console.error('Error:', error);
                setError(error); 
                toastr.error('Error occured.Try Again');
              });
          }
      };

    return (
        <>
            <Modal
                open={open}
                onClose={onClose}
                aria-labelledby="modal-modal-title"
                aria-describedby="modal-modal-description"
            >
                <Box>
                    <Container sx={style}>
                        <Box style={{ display: "flex", justifyContent: "space-between" }}>
                            <Typography variant='h6' style={{ display: "block" }}>
                                New Student Attandace
                            </Typography>
                            <IconButton onClick={onClose}>
                                <CloseIcon />
                            </IconButton>
                        </Box>
                        <Box style={{ display: "flex", justifyContent: "space-between" }}>
                            <Typography variant='h6' style={{ fontSize: "15px" }}>
                                Registration Number
                            </Typography>
                        </Box>
                        <Box style={{ display: "flex", flexdirecton: "row", justifyContent: "space-between", alignItems: "center" }}>
                            <TextField style={{ height: "60px" }}
                                margin="normal"
                                required
                                fullWidth
                                id="registrationNumber"
                                label="Registration Number"
                                name="registrationNumber"
                                autoComplete="off"
                                autoFocus
                                value={registrationNumber}
                                onChange={handleRegistrationNumberChange}
                            />
                              {error && <p style={{ color: 'red' }}>{error}</p>}
                        </Box>
                        <Button variant='contained' onClick={senddata}>Add</Button>
                    </Container>

                </Box>
            </Modal>
        </>
    )
}
