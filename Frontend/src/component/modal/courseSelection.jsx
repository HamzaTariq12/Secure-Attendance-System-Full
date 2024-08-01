import React, { useState, useEffect } from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Modal from '@mui/material/Modal';
import { Container, IconButton, Button } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import { apiGetRequest, apiPostRequest } from 'services/apiService';
import { HashLoader } from 'react-spinners';

// component importing
import Qrcode from 'component/modal/qrcode';
import ManualAttendance from 'component/modal/manualAttendance';

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
export default function CourseSelection({ open, onClose }) {

    const [isCustomAttendanceModal, setIsCustomAttendanceModal] = useState(false);
    const [courseSelection, setCourseSelection] = useState();
    const [attendance, setAttendance] = useState('0');
    const [latLng, setLatLng] = useState(null);
    const [allCourseSelection, setAllCourseSelection] = useState([]);
    const [qrString, setQrString] = useState("");
    const [loading, setLoading] = useState(true);
    const handleOpenCustomAttendanceModal = (e) => {

        if (latLng != null) {
        const apiUrl = `teacher-courses/attendance/`

        const body = {
            "att_type": e.currentTarget.id,
            "course_id": courseSelection,
            "latitude": latLng.latitude,
            "longitude": latLng.longitude,
            "ip": "0.0.0.0",
            "device": "HP"
        }
        apiPostRequest(apiUrl,false, body)
            .then(responseData => {
                if (body.att_type === "QR") {
                    setQrString(responseData.base64_data);
                    setisQRCodeModal(true);
                } else {
                    setAttendance(responseData)
                    setIsCustomAttendanceModal(true);
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
    } else {
        alert("Location Access Required");
    }
}

    const getMyLocation = () => {
        const location = window.navigator && window.navigator.geolocation;
        if (location) {
            location.getCurrentPosition((position) => {
                setLatLng(position.coords)
            }, (error) => {
                alert(error.message)
                onClose();
            },   {
                enableHighAccuracy: true, // Request high accuracy
                timeout: 10000, // Increase timeout to 10 seconds
                maximumAge: 0, // Maximum age of 0 ensures fresh location data
            })
        }
        else {
            alert("Geolocation is not supported by this browser.");
        }

    }


    const handleCloseCustomAttendanceModal = () => {
        setIsCustomAttendanceModal(false);
    };
    // below is used for QRcode opening
    const [isQRCodeModal, setisQRCodeModal] =useState(false);

    const handleClosesQRCodeModalModal = () => {
        setisQRCodeModal(false);
    };
    const handleChangeCource = (event) => {
        setCourseSelection(event.target.value);

    }

    useEffect(() => {
        getMyLocation();
        apiGetRequest('teacher-courses/')
            .then(showdata => {
                if (showdata.length > 0) {
                    setAllCourseSelection(showdata);
                    setCourseSelection(showdata[0].id);
                }
                setLoading(false); 
            })
            .catch(error => {
                console.error('Error:', error.message);
                setLoading(false); 
            });
    }, [])
    return (
        <>
            <div>
         
                <Modal
                    open={open}
                    onClose={onClose}
                    aria-labelledby="modal-modal-title"
                    aria-describedby="modal-modal-description"
                >
                
                    <Container sx={style}>
                    {loading ? (
                    <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                        <HashLoader color="#1976d2" />
                    </Box>
                ) : (
                    <div>
                        <Box component="form" style={{ display: "flex", flexdirecton: "row", justifyContent: "space-between" }}>
                            <Typography variant="h6" component="h2">
                                Select Course
                            </Typography>
                            <IconButton onClick={onClose}>
                                <CloseIcon />
                            </IconButton>
                        </Box>
                            <div>
                                <Box>
                                    <InputLabel id="demo-simple-select-label">Course Menu</InputLabel>
                                    <Select
                                        style={{ width: '100%' }}
                                        labelId="demo-simple-select-label"
                                        id="courseSelection"
                                        value={courseSelection || ''}
                                        onChange={handleChangeCource}
                                    >
                                        {
                                            allCourseSelection.map((data) => {
                                                return <MenuItem key={data.id} value={data.id}>{data.title}</MenuItem>;
                                            })
                                        }
                                    </Select>
                                </Box>
                                <Box style={{ display: "flex", flexdirecton: "row", justifyContent: "space-between", marginTop: "10px" }}>
                                    <Button variant="contained" id='Manual' onClick={handleOpenCustomAttendanceModal}>Manual</Button>
                                    <Button variant="contained" id='QR' onClick={handleOpenCustomAttendanceModal}>QR Generate</Button>
                                </Box>
                            </div>
                        {isCustomAttendanceModal &&
                            <ManualAttendance open={isCustomAttendanceModal} onClose={handleCloseCustomAttendanceModal} attendanceParm={attendance} />
                        }
                        {isQRCodeModal &&
                            <Qrcode open={isQRCodeModal} onClose={handleClosesQRCodeModalModal} qrString={qrString} courseClose={onClose} />
                        }
                        </div>
                  )}

                    </Container>

                </Modal>
            </div>
        </>
    )
}
