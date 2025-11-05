
## 🧭 Project Purpose and Context

This project demonstrates the **end-to-end design, deployment, and operation** of a distributed **MapReduce-style data processing system** using **PySpark on AWS Free Tier**, provisioned and managed via **Terraform**.

The goal is to:
- Build a **reproducible Spark cluster** (1 master, 2 workers) on AWS EC2.
- Use **S3 for storage** and optionally **EBS volumes** for node-level persistence.
- Analyze a **real-world dataset (≤ 2GB)** from open sources (e.g., Michigan Open Data, Kaggle, AWS Public Datasets).
- Leverage **AI tools (ChatGPT/Copilot)** to automate the design and implementation process.
- Critically evaluate the **accuracy, usability, and limitations** of AI-generated infrastructure and analytical code.

The outcome demonstrates how **AI-assisted DevOps + Data Engineering** can enhance cloud system design and accelerate deployment, while maintaining manual verification and control.

---
## 🧮 Dataset Description

### Dataset Source
This project uses the **Michigan County Health Rankings & Roadmaps 2024** dataset from the official **Michigan Open Data Portal**.

- **Dataset Name:** County Health Rankings & Roadmaps 2024  
- **Source:** [https://data.michigan.gov/Health-Wellness/County-Health-Rankings-Roadmaps-2024/vq8h-jb3g](https://data.michigan.gov/Health-Wellness/County-Health-Rankings-Roadmaps-2024/vq8h-jb3g)  
- **Download Link (CSV):** [Direct Download](https://data.michigan.gov/api/views/vq8h-jb3g/rows.csv?accessType=DOWNLOAD)  
- **File Size:** Approximately 5–10 MB  
- **Format:** CSV  
- **License:** Open Government License (free to use for research/academic purposes)  

### Data Fields (Partial List)
| Column Name | Description |
|--------------|-------------|
| `county_name` | Michigan county name |
| `population` | County population |
| `premature_death` | Years of potential life lost per 100,000 population |
| `adult_obesity` | Percentage of adults that are obese |
| `physical_inactivity` | Percentage of adults physically inactive |
| `primary_care_physicians_ratio` | Population to primary care physician ratio |
| `preventable_hospital_stays` | Preventable hospital stays per 100,000 Medicare enrollees |
| `high_school_graduation` | Percent of ninth-grade cohort that graduates in four years |
| `median_household_income` | Median household income in dollars |

### Analytical Potential
This dataset enables several MapReduce-style computations:
1. **Aggregation:**  
   Compute average health outcomes (`mean(adult_obesity)`) grouped by county.
2. **Correlation:**  
   Explore relationships between `median_household_income` and `adult_obesity`.
3. **Ranking:**  
   Rank counties by `preventable_hospital_stays` or `physical_inactivity`.
4. **Trend Analysis:**  
   Compare health and economic indicators to identify disparities.

### Storage and Access
Upload this dataset to your AWS S3 bucket created by Terraform:
```bash
aws s3 cp michigan_health_2024.csv s3://<your-bucket-name>/input/michigan_health_2024.csv

```

## ⚙️ System Architecture Overview

### 🏗️ Components

| Layer | Technology | Description |
|--------|-------------|-------------|
| **Infrastructure as Code (IaC)** | Terraform | Automates provisioning of AWS resources including VPC, Subnets, Security Groups, IAM Roles, EC2 instances, and S3 bucket. |
| **Compute Layer** | AWS EC2 | 3 instances (1 master, 2 workers) running Spark 3.5.x on Ubuntu 22.04 LTS. |
| **Data Storage** | Amazon S3 | Serves as the main input/output data repository for Spark. |
| **Analytics Engine** | PySpark | Performs distributed computations following MapReduce-style transformations (map, reduce, group, aggregate). |
| **Visualization Layer** | AWS QuickSight / Python Matplotlib | Converts output summaries into trend/correlation charts. |
| **Automation + AI** | ChatGPT (GPT-5) | Used to generate Terraform code, bootstrap scripts, and analytical workflow. Evaluation included. |

### 🔐 AWS Resources Created
- 1 × **VPC** with public subnets and route tables  
- 1 × **Internet Gateway**  
- 1 × **Security Group** with inbound ports 22, 7077, 8080–8081, 4040–4050  
- 1 × **IAM Role** and **Instance Profile** with S3 access policy  
- 3 × **EC2 Instances** (1 Master + 2 Workers)  
- 1 × **S3 Bucket** for dataset storage and output persistence  

### ⚡ Cluster Topology

```

+---------------------------------------------------+
| Spark Master (t3.micro)                           |
|  - Spark Master Daemon (7077)                     |
|  - Web UI (8080)                                 |
|  - S3 Connector (s3a://)                         |
|         ↑             ↑                          |
|         |             |                          |
| Spark Worker 1        Spark Worker 2             |
|  - Executor JVMs      - Executor JVMs            |
|  - Web UI (8081)      - Web UI (8081)            |
+---------------------------------------------------+

```

---

## 📂 Project Structure

```

mapreduce-aws/
├── README.md                          ← Complete project documentation
├── terraform/
│   ├── main.tf                        ← Entry point, loads all resource modules
│   ├── variables.tf                   ← Parameter definitions for region, instance type, etc.
│   ├── outputs.tf                     ← Exports Spark master IP and S3 bucket
│   ├── vpc.tf                         ← Network and routing infrastructure
│   ├── security.tf                    ← Security group with firewall rules
│   ├── iam.tf                         ← IAM role/policy for S3 access
│   ├── s3.tf                          ← Creates S3 bucket with restrictions
│   ├── ec2.tf                         ← Launches master and worker EC2 instances
│   ├── user_data_master.sh            ← Installs Spark and configures master node
│   └── user_data_worker.sh            ← Installs Spark and connects worker to master
├── spark-job/
│   ├── job.py                         ← PySpark script for group, sum, mean, or correlation
│   └── requirements.txt               ← Local Python libraries for testing
├── docs/
│   ├── AI_Interaction_Log.md          ← Verbatim chat transcript for AI documentation
│   ├── AI_Interaction_Log_Template.md ← Template for documenting AI usage
│   └── Report_Structure_Template.md   ← Recommended academic report outline
└── sample-data/
└── michigan_data.csv              ← Example dataset for demonstration

````

---

## 🚀 Deployment Workflow

### Step 1: Configure Terraform
Create a `terraform.tfvars` file:
```hcl
region         = "us-east-1"
project_name   = "mr-pyspark"
ssh_public_key = file("~/.ssh/id_rsa.pub")
instance_type  = "t3.micro"
s3_bucket_name = "mr-pyspark-demo-uniqueid"
````

### Step 2: Initialize & Apply

```bash
cd terraform
terraform init
terraform plan -out plan.out
terraform apply plan.out
```

**Result:**

* Creates EC2 master & workers
* Configures Spark & IAM automatically
* Outputs master public IP and S3 bucket name

---

### Step 3: Upload Dataset

```bash
aws s3 cp ./sample-data/michigan_data.csv s3://<your-bucket>/input/data.csv
```

---

### Step 4: SSH into Master

```bash
ssh -i ~/.ssh/id_rsa ubuntu@<MASTER_PUBLIC_IP>
```

Verify:

* Spark UI → `http://<MASTER_PUBLIC_IP>:8080`
* Worker UIs → `http://<WORKER_PUBLIC_IP>:8081`

---

### Step 5: Run MapReduce Job

```bash
/opt/spark/bin/spark-submit \
  --master spark://$(hostname -I | awk '{print $1}'):7077 \
  --packages org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.651 \
  /home/ubuntu/job/job.py \
  --input s3a://<bucket>/input/data.csv \
  --output s3a://<bucket>/output/results \
  --group_col county \
  --value_col population \
  --stat mean
```

or if data copied to s3 bucket then

```bash
/opt/spark/bin/spark-submit \
  --master spark://<MASTER_PRIVATE_IP>:7077 \
  /home/ubuntu/job/job.py \
  --input s3a://<your-bucket>/input/michigan_health_2024.csv \
  --output s3a://<your-bucket>/output/health_summary \
  --group_col county_name \
  --value_col adult_obesity \
  --stat mean
```

This job:

* Reads the CSV from S3
* Converts it to Spark DataFrame
* Performs a distributed groupBy/aggregation
* Writes summarized results back to S3 (`/output/results/`)

---

### Step 6: Validate Results

```bash
aws s3 ls s3://<bucket>/output/results/
aws s3 cp s3://<bucket>/output/results/part-00000.csv .
```

Example Output:

| county  | mean_population |
| ------- | --------------- |
| Wayne   | 523000          |
| Oakland | 310000          |
| Kent    | 189000          |

---

## 🧰 Debugging and Validation

| Issue                       | Possible Cause                           | Fix                                                        |
| --------------------------- | ---------------------------------------- | ---------------------------------------------------------- |
| Workers not appearing in UI | Incorrect master IP or network misconfig | Check `user_data_worker.sh` and re-run `terraform apply`.  |
| S3 Access Denied            | IAM role misconfigured                   | Verify EC2 has instance profile attached.                  |
| Job hangs                   | Dataset too large for t3.micro           | Use smaller dataset or increase instance size to t3.small. |
| Output empty                | Wrong column names                       | Inspect schema via `df.printSchema()`.                     |
| Spark UI inaccessible       | Security Group issue                     | Ensure inbound ports 8080/8081 open for your IP.           |

### Quick Cluster Checks

```bash
# On Master:
/opt/spark/sbin/start-master.sh
/opt/spark/sbin/start-slave.sh spark://<master-private-ip>:7077
/opt/spark/bin/spark-shell
```

---

## 🧠 Performance and Scaling Notes

* For large datasets, replace `t3.micro` with `t3.small` or `t3.medium`.
* Spark default parallelism may be tuned using:

  ```bash
  spark-submit --conf spark.default.parallelism=4 ...
  ```
* EBS volumes can be mounted to store intermediate data for HDFS-like behavior.
* Use S3A connector parameters in `/opt/spark/conf/spark-defaults.conf` for better throughput.

---

## 🧩 AI Integration and Evaluation

This project was partially generated through **AI assistance** (ChatGPT GPT-5).
The AI was used to:

* Generate initial Terraform templates.
* Create user-data bootstrap scripts for Spark configuration.
* Develop PySpark analysis script.
* Structure documentation templates.

Each AI output was:

* **Manually validated and debugged.**
* **Modified** for free-tier optimization and security compliance.
* **Tested** for deployment correctness.

### Evaluation Criteria (for report):

| Aspect               | AI Accuracy | Human Correction       |
| -------------------- | ----------- | ---------------------- |
| Terraform Networking | 9/10        | Minimal adjustments    |
| IAM/S3 Permissions   | 7/10        | Tightened security     |
| Spark Configuration  | 8/10        | Tuned paths and memory |
| Code Readability     | 10/10       | Directly usable        |

---

## 🧩 Troubleshooting Quick Reference

| Symptom                               | Diagnostic Command             | Solution                                           |
| ------------------------------------- | ------------------------------ | -------------------------------------------------- |
| “Permission denied (publickey)”       | Check `~/.ssh/id_rsa.pub` path | Ensure correct SSH key used in `terraform.tfvars`. |
| Spark job fails with `S3A auth error` | `aws sts get-caller-identity`  | IAM role not attached — reapply Terraform.         |
| “Address already in use”              | `sudo lsof -i :7077`           | Stop old Spark instance and restart.               |
| Output missing                        | Check `spark-submit` logs      | Schema mismatch — fix column names.                |

---

## 🧹 Teardown

Always clean up resources after testing to avoid charges:

```bash
cd terraform
terraform destroy -auto-approve
```

---

## 🔒 Security & Cost Optimization

* Security group ports (8080/8081/22) should be **restricted to your IP**.
* IAM role limited to **specific S3 bucket** (least privilege).
* Always use **Free Tier instances**.
* Destroy infrastructure post-demo.
* Avoid embedding AWS credentials in scripts — use IAM roles only.

---

## 📊 Example Analysis Use Cases

* Relationship between **CO₂ emissions** and **average commute time** in Michigan.
* Correlation between **population density** and **hospital distribution**.
* Seasonal trend of **energy consumption** vs **temperature**.
* Ranking counties by **education performance index**.

---

## 🧾 Academic Deliverables

| Deliverable        | Description                    | File                                |
| ------------------ | ------------------------------ | ----------------------------------- |
| Project Code & IaC | Terraform + PySpark            | Entire repo                         |
| Dataset & Outputs  | Input and summarized outputs   | `sample-data/`, `output/`           |
| AI Documentation   | Prompts, responses, evaluation | `docs/AI_Interaction_Log.md`        |
| Report             | Findings, visuals, evaluation  | `docs/Report_Structure_Template.md` |

---

## 🧠 Learning Outcomes

* Deploy and manage Spark clusters via Terraform.
* Integrate AI-generated code responsibly and critically.
* Analyze large datasets on distributed systems.
* Automate infrastructure provisioning with reproducibility.

---

