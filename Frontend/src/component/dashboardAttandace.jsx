import React, { useState, useEffect } from 'react';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import { Box } from '@mui/material';
import Button from '@mui/material/Button';
import Qrcode from './modal/qrcode';
import CourseSelection from 'component/modal/courseSelection';
import { apiGetRequest } from 'services/apiService';
import { HashLoader } from 'react-spinners';
import { useNavigate } from 'react-router-dom';
export default function Attandace() {
    const navigate=useNavigate();
    const [isAddStudentModal, setAddStudentmodal] = useState(false);
    const [attendances, setAttendances] = useState([]);
    const [loading, setLoading] = useState(true);
    const [qrModalOpen, setQrModalOpen] = useState(false); 
    const [qrString, setQrString] = useState("");
    const handleOpenAddStudentModal = () => {
        setAddStudentmodal(true);
    };

    const handleCloseAddStudentModal = () => {
        setAddStudentmodal(false);
    };
    const handleActionQR = (e) => {
        const studentid = e.target.id;
        setLoading(true);
        apiGetRequest(`teacher-courses/attendance/qr/${studentid}`)
        .then(data => {
            setQrString(data.base64_data);
            const logData=data.base64_data;
            console.log("qr detail ",logData)
             setLoading(false);
             setQrModalOpen(true); 
        })
        .catch(error => {
            console.error('Error:', error);
            alert(error);
            setLoading(false);
        });
      

    };

    const handleActionDetails = (e) => {
        const attendanceId = e.target.id;
        navigate(`/detailscreen/${attendanceId}`);
    };

    useEffect(() => {
        apiGetRequest('teacher-courses/attendance/')
            .then(data => {
                setAttendances(data);
                setLoading(false);
            })
            .catch(error => {
                console.error('Error:', error);
                alert(error);
                setLoading(false); 
            });
    }, []);

    return (
        <>
          
            <TableContainer component={Paper} style={{ paddingBottom: "20px" }}>
                <Box style={{ display: "flex", justifyContent: "space-between", paddingTop: "20px", paddingLeft: "20px", paddingRight: "20px" }}>
                    <Typography variant="h5" gutterBottom>
                        Attendance information
                    </Typography>
                    <Button variant="contained" color="primary" onClick={handleOpenAddStudentModal}>
                        Take Attendance
                    </Button>
                </Box>
                {loading ? (
                    <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                        <HashLoader color="#1976d2" />
                    </Box>
                ) : (
                    <Table style={{ zIndex: "-1" }}>
                        <TableHead>
                            <TableRow>
                                <TableCell>Date</TableCell>
                                <TableCell>Time</TableCell>
                                <TableCell>Course</TableCell>
                                <TableCell>Attendance Type</TableCell>
                                <TableCell>Total Student</TableCell>
                                <TableCell>Present</TableCell>
                                <TableCell>Absent</TableCell>
                                <TableCell>Actions</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {attendances.map((student) => (
                                <TableRow key={student.id}>
                                    <TableCell>{new Date(student.created_at).toLocaleDateString()}</TableCell>
                                    <TableCell>{new Date(student.created_at).toLocaleTimeString()}</TableCell>
                                    <TableCell>{student.course_id.title}</TableCell>
                                    <TableCell>{student.att_type}</TableCell>
                                    <TableCell>{student.details_students_count.total}</TableCell>
                                    <TableCell>{student.details_students_count.present}</TableCell>
                                    <TableCell>{student.details_students_count.absent}</TableCell>
                                    <TableCell>
                                        <Button id={student.id} onClick={handleActionDetails}>
                                            Details
                                        </Button>
                                        {student.att_type === "QR" && (<Button id={student.id} onClick={handleActionQR}>QR</Button>)}

                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                )}
            </TableContainer>
            {isAddStudentModal &&
                <CourseSelection open={isAddStudentModal} onClose={handleCloseAddStudentModal} />
            }
              {qrModalOpen && <Qrcode open={qrModalOpen} onClose={() => setQrModalOpen(false)} qrString={qrString} />}
        </>
    )
}