import * as THREE from "https://cdn.skypack.dev/three@0.129.0/build/three.module.js";
import { OrbitControls } from "https://cdn.skypack.dev/three@0.129.0/examples/jsm/controls/OrbitControls.js";
import { GLTFLoader } from "https://cdn.skypack.dev/three@0.129.0/examples/jsm/loaders/GLTFLoader.js";

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.getElementById("container3D").appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
camera.position.set(0, 2, 10);
controls.update();

const light = new THREE.DirectionalLight(0xffffff, 1);
light.position.set(10, 10, 10).normalize();
scene.add(light);

const loader = new GLTFLoader();
let robot;

loader.load('models/UR5/UR5.gltf', (gltf) => {
    robot = gltf.scene;
    robot.scale.setScalar(4);
    robot.position.y = -10;
    robot.position.z = -10;
    scene.add(robot);

    // Add slider controls for each joint after the model is loaded
    addSliderControls();
}, undefined, (error) => {
    console.error(error);
});

// Define the DH parameters
const dhParameters = [
    { a: 0, alpha: Math.PI / 2, d: 0.08916, theta: 0 },
    { a: -0.425, alpha: 0, d: 0, theta: 0 },
    { a: -0.39225, alpha: 0, d: 0, theta: 0 },
    { a: 0, alpha: Math.PI / 2, d: 0.10915, theta: 0 },
    { a: 0, alpha: -Math.PI / 2, d: 0.09465, theta: 0 },
    { a: 0, alpha: 0, d: 0.0823, theta: 0 }
];

function createDHMatrix(a, alpha, d, theta) {
    const matrix = new THREE.Matrix4();
    matrix.set(
        Math.cos(theta), -Math.sin(theta) * Math.cos(alpha), Math.sin(theta) * Math.sin(alpha), a * Math.cos(theta),
        Math.sin(theta), Math.cos(theta) * Math.cos(alpha), -Math.cos(theta) * Math.sin(alpha), a * Math.sin(theta),
        0, Math.sin(alpha), Math.cos(alpha), d,
        0, 0, 0, 1
    );
    return matrix;
}

function addSliderControls() {
    const sliders = [
        { id: 'myRange_J1', joint: 'ur5_36', axis: 'y', valueDisplay: 'valueDisplay_J1', index: 0 },
        { id: 'myRange_J2_Plane003', joint: 'ur5_47', axis: 'x', valueDisplay: 'valueDisplay_J2', index: 1 },
        { id: 'myRange_J3_Cube', joint: 'ur5_55', axis: 'y', valueDisplay: 'valueDisplay_J3', index: 2 },
        { id: 'myRange_J4', joint: 'ur5_18', axis: 'y', valueDisplay: 'valueDisplay_J4', index: 3 },
        { id: 'myRange_J5', joint: 'ur5_2', axis: 'x', valueDisplay: 'valueDisplay_J5', index: 4 },
        { id: 'myRange_J6', joint: 'ur5_10', axis: 'y', valueDisplay: 'valueDisplay_J6', index: 5 }
    ];

    sliders.forEach(slider => {
        const input = document.getElementById(slider.id);
        const display = document.getElementById(slider.valueDisplay);
        input.addEventListener('input', (event) => {
            const value = event.target.value;
            const radians = value * Math.PI / 180; // Convert to radians
            display.textContent = value;

            if (robot) {
                const joint = robot.getObjectByName(slider.joint);
                if (joint) {
                    joint.rotation[slider.axis] = radians;
                }

                dhParameters[slider.index].theta = radians; // Update DH parameters
                updateTransformationMatrix();
            }
        });
    });
}

document.getElementById('resetButton').addEventListener('click', function () {
    document.querySelectorAll('.slider').forEach(function (slider) {
        slider.value = 0;
        const event = new Event('input');
        slider.dispatchEvent(event);
    });
});

function updateTransformationMatrix() {
    let cumulativeMatrix = new THREE.Matrix4().identity();

    dhParameters.forEach(dh => {
        const dhMatrix = createDHMatrix(dh.a, dh.alpha, dh.d, dh.theta);
        cumulativeMatrix.multiply(dhMatrix);
    });

    // Update the display
    const matrix = cumulativeMatrix;
    const transformationMatrixDisplay = document.getElementById('transformationMatrix');
    transformationMatrixDisplay.innerHTML = `
        <pre>${matrix.elements[0].toFixed(2)} ${matrix.elements[1].toFixed(2)} ${matrix.elements[2].toFixed(2)} ${matrix.elements[3].toFixed(2)}
        ${matrix.elements[4].toFixed(2)} ${matrix.elements[5].toFixed(2)} ${matrix.elements[6].toFixed(2)} ${matrix.elements[7].toFixed(2)}
        ${matrix.elements[8].toFixed(2)} ${matrix.elements[9].toFixed(2)} ${matrix.elements[10].toFixed(2)} ${matrix.elements[11].toFixed(2)}
        ${matrix.elements[12].toFixed(2)} ${matrix.elements[13].toFixed(2)} ${matrix.elements[14].toFixed(2)} ${matrix.elements[15].toFixed(2)}
        </pre>`;
}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
}

window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});

animate();
