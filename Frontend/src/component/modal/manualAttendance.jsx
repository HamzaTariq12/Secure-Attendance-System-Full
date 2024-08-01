import React, { useState, useEffect } from 'react'
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Modal from '@mui/material/Modal';
import { Button, IconButton } from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import Table from '@mui/material/Table';
import TableBody from '@mui/material/TableBody';
import TableCell from '@mui/material/TableCell';
import TableContainer from '@mui/material/TableContainer';
import TableHead from '@mui/material/TableHead';
import TableRow from '@mui/material/TableRow';
import Paper from '@mui/material/Paper';

import MenuItem from '@mui/material/MenuItem';
import Select from '@mui/material/Select';
import { apiGetRequest, apiPostRequest } from 'services/apiService';
import { useNavigate } from 'react-router-dom';
import { HashLoader } from 'react-spinners';
// componnet import
import NewStudent from 'component/modal/newStudent';
const style = {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    width: 1000,
    height: 600,
    bgcolor: 'background.paper',
    border: '2px solid #000',
    boxShadow: 24,
    p: 1,
};
export default function ManualAttendance({ open, onClose, attendanceParm }) {
    const [attendanceType, setAttendanceType] = useState([]);
    const [studentDataList, setStudentDataList] = useState([]);
    const [attendance] = useState(attendanceParm);
    const [isAllPresent, setIsAllPresent] = useState(false)
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();
    const handleChange = (event, studentId) => {
        if (studentId) {
            const newAttendanceTypes = { ...attendanceType, [studentId]: event.target.value };
            setAttendanceType(newAttendanceTypes);
        } else {
            setIsAllPresent(event.target.value === "Present");
            const newAttendanceTypes = {};
            studentDataList.forEach((student) => {
                newAttendanceTypes[student.id] = event.target.value;
            })
            console.log(newAttendanceTypes)
            setAttendanceType(newAttendanceTypes);
        }
    };
    // open new Student modal
    const [isNewStudent, setNewStudent] = React.useState(false);
    const handleOpenneewStudent = () => {
        setNewStudent(true);
    };

    const handleClosesneewStudent = () => {
        setNewStudent(false);
    };
    const onNewStudentAdded = (student) => {
        setNewStudent(false);
        if (student) {
            studentDataList.push(student);
            attendanceType[student.id] = "Present";
        }

    };

    const handleSaveAction = () => {
        const result = Object.entries(attendanceType).map(([student_id
            , status]) => ({
                student_id
                , status
            }));

        apiPostRequest(`teacher-courses/attendance/mark/manual/${attendance.id}`, result).then((responseData) => {
            navigate('/');
        }).catch((error) => {
            console.log(error)
        })
    };
    // const 
    useEffect(() => {
        apiGetRequest(`teacher-courses/students/?course_id=${attendance.course_id.id}`)
            .then(responseData => {
                setStudentDataList(responseData);
                setLoading(false)
            })
            .catch(error => {
                console.error('Error:', error.message);
            });
    }, []);

    return (
        <>
            <div>
                <Modal
                    open={open}
                    onClose={onClose}
                    aria-labelledby="modal-modal-title"
                    aria-describedby="modal-modal-description"
                >
                    <TableContainer component={Paper} style={{ ...style, display: 'flex', flexDirection: 'column' }}>
                        <Box style={{ display: "flex", justifyContent: "space-between", paddingTop: "20px", paddingLeft: "20px", paddingRight: "20px" }}>
                            <Typography variant="h5" gutterBottom>
                                Course Attendance Information
                            </Typography>
                            <Button variant="contained" onClick={handleSaveAction}>Save</Button>
                            <Button variant="contained" onClick={handleOpenneewStudent}>Add custom Student</Button>
                            <IconButton onClick={onClose}>
                                <CloseIcon />
                            </IconButton>
                        </Box>
                        {loading ? (
                    <Box display="flex" justifyContent="center" alignItems="center" minHeight="200px">
                       <HashLoader color="#1976d2" />
                    </Box>
                ) : (
                        <Table style={{ overflowY: "auto" }}>
                            <TableHead>
                                <TableRow>
                                    <TableCell align='left'>ID</TableCell>
                                    <TableCell align='left'>Registration Number</TableCell>
                                    <TableCell align='left'>Full Name</TableCell>
                                    <TableCell align="right" >
                                        <Select style={{ width: "130px" }}
                                            labelId="demo-simple-select-label"
                                            id="demo-simple-select"
                                            value={isAllPresent === true ? "Present" : "Absent"}
                                            label="Attandace"
                                            onChange={(event) => handleChange(event, null)}
                                        >
                                            <MenuItem value='Present'>Present All</MenuItem>
                                            <MenuItem value='Absent'>Absent All</MenuItem>
                                        </Select>
                                    </TableCell>
                                </TableRow>
                            </TableHead>
                            <TableBody style={{ overflowY: "auto" }}>
                                {studentDataList.map((student) => (
                                    <TableRow key={student.id}>
                                        <TableCell>{student.id}</TableCell>
                                        <TableCell>{student.roll_no}</TableCell>
                                        <TableCell>{student.full_name}</TableCell>
                                        <TableCell align="right">
                                            <Select
                                                style={{ width: "130px" }}
                                                labelId={`demo-simple-select-label-${student.id}`}
                                                id={`demo-simple-select-${student.id}`}
                                                value={attendanceType[student.id] || 'Absent'}
                                                label="Attendance"
                                                onChange={(event) => handleChange(event, student.id)}
                                            >
                                                <MenuItem value='Present'>Present</MenuItem>
                                                <MenuItem value='Absent'>Absent</MenuItem>
                                            </Select>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                          )}
                    </TableContainer>
                </Modal>
                {isNewStudent &&
                    <NewStudent open={isNewStudent} onClose={handleClosesneewStudent} addedStudent={onNewStudentAdded} />
                }
            </div>
        </>
    )
}
